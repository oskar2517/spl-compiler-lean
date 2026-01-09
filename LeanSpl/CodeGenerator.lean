import LeanSpl.Table
import LeanSpl.IR
import LeanSpl.Absyn
import LeanSpl.SemanticAnalysis

namespace CodeGenerator

structure GenState where
  nextLabel : Nat := 0
  nextRegister : Nat := 0
  currentRegister : IR.Register := ⟨"0"⟩
deriving Repr, Inhabited

abbrev GenM := StateM GenState

def freshLabel : GenM IR.Label := do
  let s <- get
  let l := IR.Label.mk (toString s.nextLabel) false
  set { s with nextLabel := s.nextLabel + 1 }
  return l

def freshRegister : GenM IR.Register := do
  let s <- get
  let r : IR.Register := ⟨s!"{s.nextRegister}"⟩
  set { s with
    nextRegister := s.nextRegister + 1
    currentRegister := r
  }
  return r

def currentRegister : GenM IR.Register := do
  return (<- get).currentRegister

partial def convertTypeToLLVM : Table.SplType -> IR.LLVMType
  | .primitive .int  => .i64
  | .primitive .bool => .i1
  | .arr a           => .arr a.size (convertTypeToLLVM a.base)

def convertParameterToLLVM (p : Table.Parameter) : IR.Operand :=
  let ty := if p.is_ref then
    IR.LLVMType.ref (convertTypeToLLVM p.typ)
  else
    convertTypeToLLVM p.typ
  {
    type := ty
    register := ⟨p.name⟩
  }

def wrapInstructions (is : List IR.Instruction) : List IR.BodyElement :=
  is.map IR.BodyElement.instruction

def initializeParameters (ps : List Table.Parameter) : List IR.Instruction :=
  ps.flatMap (fun p =>
    let register := IR.Register.mk p.name
    let type := (convertParameterToLLVM p).type
    [
      IR.Instruction.alloca register.addr type,
      IR.Instruction.store type register register.addr
    ]
  )

def initializeVariables (d : Absyn.ProcDef) (localTable : Table.SymbolTable) : List IR.Instruction :=
  d.variables.map (fun v =>
    let entry := localTable.lookup none v.name
    match entry with
    | some e => match e with
      | .var ve =>
          let register := (IR.Register.mk v.name).addr
          let type := convertTypeToLLVM ve.typ

          IR.Instruction.alloca register type
      | _ => panic! s!"Internal Error: Expected variable entry"
    | _ => panic! s!"Internal Error: Symbol {d.name} not defined"
  )

mutual
  def compileExpression (expr : Absyn.Expr) (table : Table.SymbolTable) (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do
    match expr with
      | .int n =>
        let target <- freshRegister
        pure <| [IR.BodyElement.instruction <| IR.Instruction.add_ld target n]
      | .bin op left right =>
        let leftInstructions <- compileExpression left table localTable
        let leftRegister <- currentRegister

        let rightInstructions <- compileExpression right table localTable
        let rightRegister <- currentRegister

        let target <- freshRegister

        let ins := match op with
          | .add => IR.Instruction.add target leftRegister rightRegister
          | .sub => IR.Instruction.sub target leftRegister rightRegister
          | .mul => IR.Instruction.mul target leftRegister rightRegister
          | .div => IR.Instruction.sdiv target leftRegister rightRegister
          | _ => panic! s!"Internal Error: Unexpected operator"

        pure <| leftInstructions ++ rightInstructions ++ [IR.BodyElement.instruction ins]
      | .un _ operand =>
        let operandInstructions <- compileExpression operand table localTable
        let operandRegister <- currentRegister

        let target <- freshRegister
        let ins := IR.Instruction.sub_imm target operandRegister

        pure <| operandInstructions ++ [IR.BodyElement.instruction ins]
      | .var var =>
        let variableInstructions <- compileVariable var table localTable
        let variableExpressionRegister <- currentRegister

        let target <- freshRegister
        let ins := IR.Instruction.load target variableExpressionRegister

        pure <| variableInstructions ++ [IR.BodyElement.instruction ins]


  def compileVariable (var : Absyn.Variable) (table : Table.SymbolTable) (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do
    match var with
    | .named name =>
      let entry := table.lookup localTable name
      match entry with
      | some e => match e with
        | .var ve =>
          let target <- freshRegister
          let value := (IR.Register.mk name).addr

          if (ve.is_ref)
            then pure <| [IR.BodyElement.instruction <| IR.Instruction.load target value]
            else pure <| [IR.BodyElement.instruction <| IR.Instruction.getelementptr_nop target value]
        | _ => panic! s!"Internal Error: Expected variable entry"
      | _ => panic! s!"Internal Error: Symbol {name} not defined"
    | .index array index =>
      let arrayType := SemanticAnalysis.varType array localTable
      match arrayType with
        | .ok ty =>
          let convertedType := convertTypeToLLVM ty

          let arrayInstructions <- compileVariable array table localTable
          let arrayRegister <- currentRegister

          let indexInstructions <- compileExpression index table localTable
          let indexRegister <- currentRegister

          let target <- freshRegister

          let ins := IR.Instruction.getelementptr target convertedType arrayRegister indexRegister

          pure <| arrayInstructions ++ indexInstructions ++ [IR.BodyElement.instruction ins]
        | _ => panic! s!"Internal error: Could not calculate type of array"

end

def compileAssignStmt (target : Absyn.Variable) (value : Absyn.Expr) (table : Table.SymbolTable) (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do
  let variableInstructions <- compileVariable target table localTable
  let addressRegister <- currentRegister

  let valueInstructions <- compileExpression value table localTable
  let valueRegister <- currentRegister

  let storeInstruction := IR.Instruction.store IR.LLVMType.i64 valueRegister addressRegister

  pure <| variableInstructions ++ valueInstructions ++ [IR.BodyElement.instruction storeInstruction]

def compileCallStmt
  (name : String)
  (arguments : List Absyn.Expr)
  (table : Table.SymbolTable)
  (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do

  let entry := table.lookup none name
  match entry with
  | some (.proc pe) =>
      let zipped := arguments.zip pe.parameters.reverse
      let argPairs <- zipped.mapM (fun (a, p) => do
        if p.is_ref then
          match a with
          | .var v => do
              let instructions <- compileVariable v table localTable
              let r <- currentRegister
              let ty := IR.LLVMType.ref (convertTypeToLLVM p.typ)
              pure (instructions, IR.Operand.mk ty r)
          | _ =>
              panic! "Internal error: ref parameter expects variable argument"
        else do
          let instructions <- compileExpression a table localTable
          let r <- currentRegister
          let ty := convertTypeToLLVM p.typ
          pure (instructions, IR.Operand.mk ty r)
      )

      let argInstrs := argPairs.foldr (fun (instrs, _) acc => instrs ++ acc) []
      let argOps := argPairs.map (fun (_, op) => op)
      let callElem := IR.BodyElement.instruction <| IR.Instruction.call (IR.Global.mk name) argOps

      pure (argInstrs ++ [callElem])
  | some _ => panic! s!"Internal Error: Expected procedure entry for {name}"
  | none => panic! s!"Internal Error: Symbol {name} not defined"

def generateCondition
  (condition : Absyn.Expr)
  (thenLabel : IR.Label)
  (elseLabel : IR.Label)
  (table : Table.SymbolTable)
  (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do

  match condition with
  | Absyn.Expr.bin op left right =>
    let leftInstructions <- compileExpression left table localTable
    let leftRegister <- currentRegister

    let rightInstructions <- compileExpression right table localTable
    let rightRegister <- currentRegister

    let target <- freshRegister

    let cmpIns := match op with
      | .eq => IR.Instruction.icmp target IR.RelOp.eq leftRegister rightRegister
      | .ne => IR.Instruction.icmp target IR.RelOp.ne leftRegister rightRegister
      | .lt => IR.Instruction.icmp target IR.RelOp.slt leftRegister rightRegister
      | .le => IR.Instruction.icmp target IR.RelOp.sle leftRegister rightRegister
      | .gt => IR.Instruction.icmp target IR.RelOp.sgt leftRegister rightRegister
      | .ge => IR.Instruction.icmp target IR.RelOp.sge leftRegister rightRegister
      | _ => panic! s!"Internal error: Unexpected operator"

    let brIns := IR.Instruction.br_con target thenLabel elseLabel

    pure <| leftInstructions ++ rightInstructions ++ [IR.BodyElement.instruction cmpIns, IR.BodyElement.instruction brIns]
  | _ => panic! s!"Internal error: Expected binary expression"

mutual
-- todo: empty statement?
  partial def compileIfStatement
    (condition : Absyn.Expr)
    (thenBranch : Absyn.Stmt)
    (elseBranch : Option Absyn.Stmt)
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do

    let thenLabel <- freshLabel
    let elseLabel <- freshLabel
    let mergeLabel <- freshLabel

    let condInstructions <- generateCondition condition thenLabel elseLabel table localTable

    let thenInstructions <- compileStatement table localTable thenBranch
    let brThenIns := IR.Instruction.br mergeLabel

    let elseInstructions <- match elseBranch with
      | some b => compileStatement table localTable b
      | _ => pure []
    let brElseIns := IR.Instruction.br mergeLabel

    pure <| condInstructions ++ [IR.BodyElement.label thenLabel] ++ thenInstructions
    ++ [IR.BodyElement.instruction brThenIns] ++ [IR.BodyElement.label elseLabel]
    ++ elseInstructions ++ [IR.BodyElement.instruction brElseIns, IR.BodyElement.label mergeLabel]

  partial def compileWhileStatement
    (condition : Absyn.Expr)
    (body : Absyn.Stmt)
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do

    let condLabel <- freshLabel
    let bodyLabel <- freshLabel
    let endLabel <- freshLabel

    let condBrIns := IR.Instruction.br condLabel

    let condInstructions <- generateCondition condition bodyLabel endLabel table localTable

    let bodyInstructions <- compileStatement table localTable body

    pure <| [IR.BodyElement.instruction condBrIns, IR.BodyElement.label condLabel] ++ condInstructions
    ++ [IR.BodyElement.label bodyLabel] ++ bodyInstructions ++ [IR.BodyElement.instruction condBrIns, IR.BodyElement.label endLabel]

  partial def compileBlockStatement (stmts : List Absyn.Stmt) (table : Table.SymbolTable) (localTable : Table.SymbolTable) : GenM (List IR.BodyElement) := do
    let blocks ← stmts.mapM (compileStatement table localTable)
    pure <| blocks.foldr (· ++ ·) []

  partial def compileStatement (table : Table.SymbolTable) (localTable : Table.SymbolTable) (s : Absyn.Stmt) : GenM (List IR.BodyElement) :=
    match s with
    | .assign target value => compileAssignStmt target value table localTable
    | .call name arguments => compileCallStmt name arguments table localTable
    | .if_ condition then_branch else_branch => compileIfStatement condition then_branch else_branch table localTable
    | .while_ condition body => compileWhileStatement condition body table localTable
    | .block stmts => compileBlockStatement stmts table localTable
    | .empty => pure []
  end

def compileProcDef (d : Absyn.ProcDef) (table : Table.SymbolTable) : GenM IR.Function := do
  let entry := table.lookup none d.name
  match entry with
  | some e => match e with
    | .proc pe => -- TODO: Parameters are reversed
      let parameters := pe.parameters.reverse.map convertParameterToLLVM
      let body := [IR.BodyElement.label <| IR.Label.mk "entry" true]
      let body := body ++ (wrapInstructions <| initializeParameters pe.parameters.reverse)
      let body := body ++ (wrapInstructions <| initializeVariables d pe.local_table)

      let stmtLists <- d.body.mapM (compileStatement table pe.local_table)
      let body := body ++ stmtLists.foldr (· ++ ·) []

      let body := body ++ [IR.BodyElement.instruction IR.Instruction.ret]

      pure {
        name := IR.Global.mk d.name
        parameters := parameters
        body := body
      }
    | _ => panic! s!"Internal Error: Expected procedure entry"
  | none => panic! s!"Internal Error: Symbol {d.name} not defined"

def compileProgram (p : Absyn.Program) (table : Table.SymbolTable) : GenM IR.Program := do
  let procDefs : List Absyn.ProcDef :=
    p.definitions.filterMap (fun
      | .procedure d => some d
      | _            => none)

  let functions <- procDefs.mapM (fun d => compileProcDef d table)

  pure {
    declarations := [],
    functions := functions
  }

end CodeGenerator
