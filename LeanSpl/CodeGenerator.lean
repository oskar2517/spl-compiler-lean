import LeanSpl.Table
import LeanSpl.IR
import LeanSpl.Absyn
import LeanSpl.SemanticAnalysis

namespace CodeGenerator

abbrev Code := Array IR.Item

@[inline] def Code.empty : Code := #[]

@[inline] def Code.emit (c : Code) (e : IR.Item) : Code :=
  c.push e

structure GenState where
  nextLabel : Nat := 0
  nextRegister : Nat := 0
deriving Repr, Inhabited

abbrev GenM := StateM GenState

def freshLabel : GenM IR.Label := do
  let s ← get
  let l : IR.Label := ⟨toString s.nextLabel, false⟩
  set { s with nextLabel := s.nextLabel + 1 }
  return l

def freshRegister : GenM IR.Register := do
  let s ← get
  let r : IR.Register := ⟨toString s.nextRegister⟩
  set { s with nextRegister := s.nextRegister + 1 }
  return r

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

def initializeParameters (ps : List Table.Parameter) : List IR.Item :=
  ps.flatMap (fun p =>
    let r := IR.Register.mk p.name
    let ty := (convertParameterToLLVM p).type
    [
      IR.Instruction.alloca r.addr ty,
      IR.Instruction.store ty r r.addr
    ]
  )

def initializeVariables (d : Absyn.ProcDef) (localTable : Table.SymbolTable) : List IR.Item :=
  d.variables.map (fun v =>
    let entry := localTable.lookup v.name
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
  def compileExpression
    (expr : Absyn.Expr)
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable)
    : GenM (Code × IR.Register) := do

    match expr with
    | .int n =>
      let target ← freshRegister
      let code := Code.empty.emit <| IR.Instruction.add_ld target n
      pure (code, target)

    | .bin op left right =>
      let (lc, lreg) ← compileExpression left table localTable
      let (rc, rreg) ← compileExpression right table localTable
      let target ← freshRegister

      let ins := match op with
        | .add => IR.Instruction.add target lreg rreg
        | .sub => IR.Instruction.sub target lreg rreg
        | .mul => IR.Instruction.mul target lreg rreg
        | .div => IR.Instruction.sdiv target lreg rreg
        | _    => panic! "Internal Error: Unexpected operator"

      let code := lc ++ rc |>.emit ins
      pure (code, target)

    | .un _ operand =>
      let (oc, oreg) ← compileExpression operand table localTable
      let target ← freshRegister
      let code := oc.emit <| IR.Instruction.sub_imm target oreg
      pure (code, target)

    | .var v =>
      let (vc, addr) ← compileVariable v table localTable
      let target ← freshRegister
      let code := vc.emit <| IR.Instruction.load target IR.LLVMType.i64 addr
      pure (code, target)

  def compileVariable
    (var : Absyn.Variable)
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable)
    : GenM (Code × IR.Register) := do

    match var with
    | .named name =>
      match localTable.lookup name with
      | some (.var ve) =>
        let target ← freshRegister
        let base := (IR.Register.mk name).addr

        if ve.is_ref then
          let code := Code.empty.emit <| IR.Instruction.load target (IR.LLVMType.ref IR.LLVMType.i64) base
          pure (code, target)
        else
          let code := Code.empty.emit <| IR.Instruction.getelementptr_nop target base
          pure (code, target)

      | some _ => panic! "Internal Error: Expected variable entry"
      | none   => panic! s!"Internal Error: Symbol {name} not defined"

    | .index array index =>
      match SemanticAnalysis.varType array localTable with
      | .ok ty =>
        let convertedType := convertTypeToLLVM ty

        let (ac, areg) ← compileVariable array table localTable
        let (ic, ireg) ← compileExpression index table localTable
        let target ← freshRegister

        let code := (ac ++ ic).emit <| IR.Instruction.getelementptr target convertedType areg ireg
        pure (code, target)

      | _ => panic! "Internal error: Could not calculate type of array"
end

def compileAssignStmt
  (target : Absyn.Variable)
  (value : Absyn.Expr)
  (table : Table.SymbolTable)
  (localTable : Table.SymbolTable)
  : GenM Code := do

  let (tc, addr) ← compileVariable target table localTable
  let (vc, vreg) ← compileExpression value table localTable

  pure <| (tc ++ vc).emit <| IR.Instruction.store IR.LLVMType.i64 vreg addr

def compileCallStmt
  (name : String)
  (arguments : List Absyn.Expr)
  (table : Table.SymbolTable)
  (localTable : Table.SymbolTable)
  : GenM Code := do

  match table.lookup name with
  | some (.proc pe) =>
    let zipped := arguments.zip pe.parameters.reverse

    let mut code : Code := Code.empty
    let mut ops : Array IR.Operand := #[]

    for (a, p) in zipped do
      if p.is_ref then
        match a with
        | .var v =>
          let (c, addr) ← compileVariable v table localTable
          code := code ++ c

          let ty := IR.LLVMType.ref (convertTypeToLLVM p.typ)
          ops := ops.push (IR.Operand.mk ty addr)
        | _ =>
          panic! "Internal error: ref parameter expects variable argument"
      else
        let (c, r) ← compileExpression a table localTable
        code := code ++ c
        let ty := convertTypeToLLVM p.typ
        ops := ops.push (IR.Operand.mk ty r)

    pure <| code.emit <| IR.Instruction.call (IR.Global.mk name false) ops.toList

  | some _ => panic! s!"Internal Error: Expected procedure entry for {name}"
  | none   => panic! s!"Internal Error: Symbol {name} not defined"

def generateCondition
  (condition : Absyn.Expr)
  (thenLabel : IR.Label)
  (elseLabel : IR.Label)
  (table : Table.SymbolTable)
  (localTable : Table.SymbolTable)
  : GenM Code := do

  match condition with
  | .bin op left right =>
    let (lc, lreg) ← compileExpression left table localTable
    let (rc, rreg) ← compileExpression right table localTable
    let target ← freshRegister

    let cmpIns := match op with
      | .eq => IR.Instruction.icmp target IR.RelOp.eq  lreg rreg
      | .ne => IR.Instruction.icmp target IR.RelOp.ne  lreg rreg
      | .lt => IR.Instruction.icmp target IR.RelOp.slt lreg rreg
      | .le => IR.Instruction.icmp target IR.RelOp.sle lreg rreg
      | .gt => IR.Instruction.icmp target IR.RelOp.sgt lreg rreg
      | .ge => IR.Instruction.icmp target IR.RelOp.sge lreg rreg
      | _   => panic! "Internal error: Unexpected operator"

    let brIns := IR.Instruction.br_con target thenLabel elseLabel
    pure <| (lc ++ rc) |>.emit cmpIns |>.emit brIns

  | _ => panic! "Internal error: Expected binary expression"

mutual
  partial def compileIfStatement
    (condition : Absyn.Expr)
    (thenBranch : Absyn.Stmt)
    (elseBranch : Option Absyn.Stmt)
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable)
    : GenM Code := do

    let thenLabel ← freshLabel
    let elseLabel ← freshLabel
    let mergeLabel ← freshLabel

    let condCode ← generateCondition condition thenLabel elseLabel table localTable
    let thenCode ← compileStatement table localTable thenBranch

    let elseCode ← match elseBranch with
      | some b => compileStatement table localTable b
      | none   => pure Code.empty

    let mut code := Code.empty
    code := code ++ condCode
    code := code.emit thenLabel
    code := code ++ thenCode
    code := code.emit (IR.Instruction.br mergeLabel)
    code := code.emit elseLabel
    code := code ++ elseCode
    code := code.emit (IR.Instruction.br mergeLabel)
    code := code.emit mergeLabel
    pure code

  partial def compileWhileStatement
    (condition : Absyn.Expr)
    (body : Absyn.Stmt)
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable)
    : GenM Code := do

    let condLabel ← freshLabel
    let bodyLabel ← freshLabel
    let endLabel ← freshLabel

    let condCode ← generateCondition condition bodyLabel endLabel table localTable
    let bodyCode ← compileStatement table localTable body

    let mut code := Code.empty
    code := code.emit (IR.Instruction.br condLabel)
    code := code.emit condLabel
    code := code ++ condCode
    code := code.emit bodyLabel
    code := code ++ bodyCode
    code := code.emit (IR.Instruction.br condLabel)
    code := code.emit endLabel
    pure code

  partial def compileBlockStatement
    (stmts : List Absyn.Stmt)
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable)
    : GenM Code := do
    let mut code := Code.empty
    for s in stmts do
      let c ← compileStatement table localTable s
      code := code ++ c
    pure code

  partial def compileStatement
    (table : Table.SymbolTable)
    (localTable : Table.SymbolTable)
    (s : Absyn.Stmt)
    : GenM Code :=
    match s with
    | .assign target value => compileAssignStmt target value table localTable
    | .call name arguments => compileCallStmt name arguments table localTable
    | .if_ condition t e   => compileIfStatement condition t e table localTable
    | .while_ condition b  => compileWhileStatement condition b table localTable
    | .block stmts         => compileBlockStatement stmts table localTable
    | .empty               => pure Code.empty
end

def compileProcDef (d : Absyn.ProcDef) (table : Table.SymbolTable) : GenM IR.Function := do
  match table.lookup d.name with
  | some (.proc pe) =>
    let parameters := pe.parameters.reverse.map convertParameterToLLVM

    let mut body : Code := Code.empty
    body := body.emit <| IR.Label.mk "entry" true

    body := body ++ (initializeParameters pe.parameters.reverse).toArray
    body := body ++ (initializeVariables d pe.local_table).toArray

    for s in d.body do
      let c ← compileStatement table pe.local_table s
      body := body ++ c

    body := body.emit IR.Instruction.ret

    pure {
      name := IR.Global.mk d.name false
      type := IR.LLVMType.void
      parameters := parameters
      body := body.toList
    }

  | some _ => panic! "Internal Error: Expected procedure entry"
  | none   => panic! s!"Internal Error: Symbol {d.name} not defined"

def compileProgram (p : Absyn.Program) (table : Table.SymbolTable) : GenM IR.Program := do
  let procDefs : List Absyn.ProcDef :=
    p.definitions.filterMap (fun
      | .procedure d => some d
      | _            => none)

  let main : IR.Function := {
    name := ⟨"main", true⟩
    type := IR.LLVMType.i32
    parameters := [],
    body := [
      IR.Label.mk "entry" true,
      IR.Instruction.call ⟨"__init_time", true⟩ [],
      IR.Instruction.call ⟨"__sdl_init_screen", true⟩ [],
      IR.Instruction.call ⟨"main", false⟩ [],
      IR.Instruction.call ⟨"__sdl_event_loop", true⟩ [],
      IR.Instruction.ret_null IR.LLVMType.i32
    ]
  }

  let functions ← procDefs.mapM (fun d => compileProcDef d table)
  let declarations : List IR.Declaration :=
    table.builtinProcedures.map (fun (procName, pe) =>
      { name := IR.Global.mk procName false
        parameters := pe.parameters.reverse.map (fun p =>
          if p.is_ref then
            IR.LLVMType.ref (convertTypeToLLVM p.typ)
          else
            convertTypeToLLVM p.typ) })

  let declarations := declarations ++ [
    ⟨⟨"__init_time", true⟩, []⟩,
    ⟨⟨"__sdl_init_screen", true⟩, []⟩,
    ⟨⟨"__sdl_event_loop", true⟩, []⟩
  ]

  pure {
    declarations := declarations,
    functions := main :: functions
  }

end CodeGenerator
