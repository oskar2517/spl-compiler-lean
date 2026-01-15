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
  globalTable : Table.SymbolTable
  localTable : Table.SymbolTable
deriving Repr

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

open IR.Instruction

def initializeParameters (ps : List Table.Parameter) : List IR.Item :=
  ps.flatMap (fun p =>
    let r := IR.Register.mk p.name
    let ty := (convertParameterToLLVM p).type
    [
      alloca r.addr ty,
      store ty r r.addr
    ]
  )

def initializeVariables (d : Absyn.ProcDef) (localTable : Table.SymbolTable) : List IR.Item :=
  d.variables.map (fun v =>
    match localTable.lookup v.name with
    | .ok (.var ve) =>
        let r := (IR.Register.mk v.name).addr
        let ty := convertTypeToLLVM ve.typ
        alloca r ty
    | _ => panic!"Internal Erorr: Could not lookup variable"
  )

mutual
  def compileExpression (expr : Absyn.Expr): GenM (Code × IR.Register) := do
    match expr with
    | .int n =>
      let target ← freshRegister
      let code := Code.empty.emit <| add_ld target n
      pure (code, target)

    | .bin op left right =>
      let (lc, lreg) ← compileExpression left
      let (rc, rreg) ← compileExpression right
      let target ← freshRegister

      let ins := match op with
        | .add => add target lreg rreg
        | .sub => sub target lreg rreg
        | .mul => mul target lreg rreg
        | .div => sdiv target lreg rreg
        | _    => panic! "Internal Error: Unexpected operator"

      let code := lc ++ rc |>.emit ins
      pure (code, target)

    | .un _ operand =>
      let (oc, oreg) ← compileExpression operand
      let target ← freshRegister
      let code := oc.emit <| sub_imm target oreg
      pure (code, target)

    | .var v =>
      let (vc, addr) ← compileVariable v
      let target ← freshRegister
      let code := vc.emit <| load target IR.LLVMType.i64 addr
      pure (code, target)

  def compileVariable (var : Absyn.Variable) : GenM (Code × IR.Register) := do
    let localTable := (← get).localTable

    match var with
    | .named name =>
      match localTable.lookup name with
      | .ok (.var ve) =>
        let target ← freshRegister
        let base := (IR.Register.mk name).addr

        if ve.is_ref then
          let code := Code.empty.emit <| load target (IR.LLVMType.ref IR.LLVMType.i64) base
          pure (code, target)
        else
          let code := Code.empty.emit <| getelementptr_nop target base
          pure (code, target)

      | _ => panic! "Internal Error: Could not lookup variable"

    | .index array index =>
      match SemanticAnalysis.varType array localTable with
      | .ok ty =>
        let convertedType := convertTypeToLLVM ty

        let (ac, areg) ← compileVariable array
        let (ic, ireg) ← compileExpression index
        let target ← freshRegister

        let code := (ac ++ ic).emit <| getelementptr target convertedType areg ireg
        pure (code, target)

      | _ => panic! "Internal error: Could not calculate type of array"
end

def compileAssignStmt (target : Absyn.Variable) (value : Absyn.Expr) : GenM Code := do
  let (tc, addr) ← compileVariable target
  let (vc, vreg) ← compileExpression value

  pure <| (tc ++ vc).emit <| store IR.LLVMType.i64 vreg addr

def compileCallStmt (name : String) (arguments : List Absyn.Expr): GenM Code := do
  let globalTable := (← get).globalTable

  match globalTable.lookup name with
  | .ok (.proc pe) =>
    let zipped := arguments.zip pe.parameters.reverse

    let mut code : Code := Code.empty
    let mut ops : Array IR.Operand := #[]

    for (a, p) in zipped do
      if p.is_ref then
        match a with
        | .var v =>
          let (c, addr) ← compileVariable v
          code := code ++ c

          let ty := IR.LLVMType.ref (convertTypeToLLVM p.typ)
          ops := ops.push (IR.Operand.mk ty addr)
        | _ =>
          panic! "Internal error: ref parameter expects variable argument"
      else
        let (c, r) ← compileExpression a
        code := code ++ c
        let ty := convertTypeToLLVM p.typ
        ops := ops.push (IR.Operand.mk ty r)

    pure <| code.emit <| call (IR.Global.mk name false) ops
  | _ => panic! s!"Internal Error: Could not lookup procedure entry"

def generateCondition
  (condition : Absyn.Expr)
  (thenLabel : IR.Label)
  (elseLabel : IR.Label)
  : GenM Code := do

  match condition with
  | .bin op left right =>
    let (lc, lreg) ← compileExpression left
    let (rc, rreg) ← compileExpression right
    let target ← freshRegister

    let cmpIns := match op with
      | .eq => icmp target IR.RelOp.eq  lreg rreg
      | .ne => icmp target IR.RelOp.ne  lreg rreg
      | .lt => icmp target IR.RelOp.slt lreg rreg
      | .le => icmp target IR.RelOp.sle lreg rreg
      | .gt => icmp target IR.RelOp.sgt lreg rreg
      | .ge => icmp target IR.RelOp.sge lreg rreg
      | _   => panic! "Internal error: Unexpected operator"

    let brIns := br_con target thenLabel elseLabel
    pure <| (lc ++ rc) |>.emit cmpIns |>.emit brIns

  | _ => panic! "Internal error: Expected binary expression"

mutual
  partial def compileIfStatement
    (condition : Absyn.Expr)
    (thenBranch : Absyn.Stmt)
    (elseBranch : Option Absyn.Stmt)
    : GenM Code := do

    let thenLabel ← freshLabel
    let elseLabel ← freshLabel
    let mergeLabel ← freshLabel

    let condCode ← generateCondition condition thenLabel elseLabel
    let thenCode ← compileStatement thenBranch

    let elseCode ← match elseBranch with
      | some b => compileStatement b
      | none   => pure Code.empty

    let mut code := Code.empty
    code := code ++ condCode
    code := code.emit thenLabel
    code := code ++ thenCode
    code := code.emit (br mergeLabel)
    code := code.emit elseLabel
    code := code ++ elseCode
    code := code.emit (br mergeLabel)
    code := code.emit mergeLabel
    pure code

  partial def compileWhileStatement (condition : Absyn.Expr) (body : Absyn.Stmt) : GenM Code := do
    let condLabel ← freshLabel
    let bodyLabel ← freshLabel
    let endLabel ← freshLabel

    let condCode ← generateCondition condition bodyLabel endLabel
    let bodyCode ← compileStatement body

    let mut code := Code.empty
    code := code.emit (br condLabel)
    code := code.emit condLabel
    code := code ++ condCode
    code := code.emit bodyLabel
    code := code ++ bodyCode
    code := code.emit (br condLabel)
    code := code.emit endLabel
    pure code

  partial def compileBlockStatement (stmts : List Absyn.Stmt): GenM Code := do
    let mut code := Code.empty
    for s in stmts do
      let c ← compileStatement s
      code := code ++ c
    pure code

  partial def compileStatement (s : Absyn.Stmt) : GenM Code :=
    match s with
    | .assign target value => compileAssignStmt target value
    | .call name arguments => compileCallStmt name arguments
    | .if_ condition t e   => compileIfStatement condition t e
    | .while_ condition b  => compileWhileStatement condition b
    | .block stmts         => compileBlockStatement stmts
    | .empty               => pure Code.empty
end

def compileProcDef (d : Absyn.ProcDef): GenM IR.Function := do
  let s <- get
  let globalTable := s.globalTable

  match globalTable.lookup d.name with
  | .ok (.proc pe) =>
    set { s with localTable := pe.local_table }

    let parameters := pe.parameters.reverse.map convertParameterToLLVM |>.toArray

    let mut body : Code := Code.empty
    body := body.emit <| IR.Label.mk "entry" true

    body := body ++ (initializeParameters pe.parameters.reverse).toArray
    body := body ++ (initializeVariables d pe.local_table).toArray

    for s in d.body do
      let c ← compileStatement s
      body := body ++ c

    body := body.emit ret

    pure {
      name := ⟨d.name, false⟩
      type := IR.LLVMType.void
      parameters := parameters
      body := body
    }

  | _ => panic! "Internal Error: Could not lookup procedure entry"

def compileProgram (p : Absyn.Program) : GenM IR.Program := do
  let globalTable := (← get).globalTable

  let procDefs : List Absyn.ProcDef :=
    p.definitions.filterMap (fun
      | .procedure d => some d
      | _            => none)

  let main : IR.Function := {
    name := ⟨"main", true⟩
    type := IR.LLVMType.i32
    parameters := #[],
    body := #[
      IR.Label.mk "entry" true,
      call ⟨"__init_time", true⟩ #[],
      call ⟨"__sdl_init_screen", true⟩ #[],
      call ⟨"main", false⟩ #[],
      call ⟨"__sdl_event_loop", true⟩ #[],
      ret_null IR.LLVMType.i32
    ]
  }

  let functions := (← procDefs.mapM (fun d => compileProcDef d)).toArray

  let declarations : Array IR.Declaration :=
    (globalTable.builtinProcedures.map (fun (procName, pe) =>
      let params :=
        (pe.parameters.reverse.map (fun p =>
          if p.is_ref then
            IR.LLVMType.ref (convertTypeToLLVM p.typ)
          else
            convertTypeToLLVM p.typ
        )).toArray

      {
        name := ⟨procName, false⟩
        parameters := params
      }
    )).toArray

  let declarations : Array IR.Declaration :=
    declarations ++ #[
      ⟨⟨"__init_time", true⟩, #[]⟩,
      ⟨⟨"__sdl_init_screen", true⟩, #[]⟩,
      ⟨⟨"__sdl_event_loop", true⟩, #[]⟩
    ]

  pure {
    declarations := declarations,
    functions := functions.push main
  }

end CodeGenerator
