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
  nextLabel := 0
  nextRegister := 0
  globalTable : Table.SymbolTable
  localTable : Table.SymbolTable := default
deriving Repr

abbrev GenM := StateM GenState

def freshLabel : GenM IR.Label := do
  let s ← get
  let l := ⟨toString s.nextLabel, false⟩
  set { s with nextLabel := s.nextLabel + 1 }
  return l

def freshRegister : GenM IR.Register := do
  let s ← get
  let r := ⟨toString s.nextRegister⟩
  set { s with nextRegister := s.nextRegister + 1 }
  return r

partial def convertTypeToLLVM : Table.SplType -> IR.LLVMType
  | .primitive .int  => .i64
  | .primitive .bool => .i1
  | .arr a           => .arr a.size (convertTypeToLLVM a.base)

def convertParameterToLLVM (p : Table.Parameter) : IR.Operand :=
  let typ := if p.is_ref then
    IR.LLVMType.ref (convertTypeToLLVM p.typ)
  else
    convertTypeToLLVM p.typ
  {
    type := typ
    register := ⟨p.name⟩
  }

open IR.Instruction

def initializeParams (ps : List Table.Parameter) : List IR.Item :=
  ps.flatMap (fun p =>
    let r := ⟨p.name⟩
    let typ := (convertParameterToLLVM p).type
    [ alloca r.addr typ
    , store typ r r.addr
    ]
  )

def initializeVars (d : Absyn.ProcDef) (locTable : Table.SymbolTable) : List IR.Item :=
  d.variables.map (fun v =>
    match locTable.lookup v.name with
    | .ok (.var ve) =>
        let r := (IR.Register.mk v.name).addr
        let typ := convertTypeToLLVM ve.typ
        alloca r typ
    | _ => panic!"Internal Erorr: Could not lookup variable"
  )

mutual
  def compileExpr (expr : Absyn.Expr): GenM (Code × IR.Register) := do
    match expr with
    | .int n =>
      let target ← freshRegister
      let code := Code.empty.emit <| add_ld target n
      pure (code, target)

    | .bin op left right =>
      let (lc, lreg) ← compileExpr left
      let (rc, rreg) ← compileExpr right
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
      let (oc, oreg) ← compileExpr operand
      let target ← freshRegister
      let code := oc.emit <| sub_imm target oreg
      pure (code, target)

    | .var v =>
      let (vc, vreg) ← compileVar v
      let target ← freshRegister
      let code := vc.emit <| load target IR.LLVMType.i64 vreg
      pure (code, target)

  def compileVar (var : Absyn.Variable) : GenM (Code × IR.Register) := do
    let locTable := (← get).localTable

    match var with
    | .named name =>
      match locTable.lookup name with
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
      match SemanticAnalysis.varType array locTable with
      | .ok typ =>
        let convertedType := convertTypeToLLVM typ

        let (ac, areg) ← compileVar array
        let (ic, ireg) ← compileExpr index
        let target ← freshRegister

        let code := (ac ++ ic).emit <| getelementptr target convertedType areg ireg
        pure (code, target)

      | _ => panic! "Internal error: Could not calculate type of array"
end

def compileAssignStmt (target : Absyn.Variable) (value : Absyn.Expr) : GenM Code := do
  let (tc, addr) ← compileVar target
  let (vc, vreg) ← compileExpr value

  pure <| (tc ++ vc).emit <| store IR.LLVMType.i64 vreg addr

def compileCallStmt (name : String) (args : List Absyn.Expr): GenM Code := do
  let globTable := (← get).globalTable

  match globTable.lookup name with
  | .ok (.proc pe) =>
    let zipped := args.zip pe.parameters.reverse

    let mut code : Code := Code.empty
    let mut ops : Array IR.Operand := #[]

    for (a, p) in zipped do
      if p.is_ref then
        match a with
        | .var v =>
          let (c, vreg) ← compileVar v
          code := code ++ c

          let typ := IR.LLVMType.ref (convertTypeToLLVM p.typ)
          ops := ops.push (IR.Operand.mk typ vreg)
        | _ =>
          panic! "Internal error: ref parameter expects variable argument"
      else
        let (c, ereg) ← compileExpr a
        code := code ++ c
        let typ := convertTypeToLLVM p.typ
        ops := ops.push (IR.Operand.mk typ ereg)

    pure <| code.emit <| call (IR.Global.mk name false) ops
  | _ => panic! s!"Internal Error: Could not lookup procedure entry"

def generateCondition
  (condition : Absyn.Expr)
  (thenLabel : IR.Label)
  (elseLabel : IR.Label)
  : GenM Code := do

  match condition with
  | .bin op left right =>
    let (lc, lreg) ← compileExpr left
    let (rc, rreg) ← compileExpr right
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
  partial def compileIfStmt
    (condition : Absyn.Expr)
    (thenBranch : Absyn.Stmt)
    (elseBranch : Option Absyn.Stmt)
    : GenM Code := do

    let thenLabel ← freshLabel
    let elseLabel ← freshLabel
    let mergeLabel ← freshLabel

    let condCode ← generateCondition condition thenLabel elseLabel
    let thenCode ← compileStmt thenBranch

    let elseCode ← match elseBranch with
      | some b => compileStmt b
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

  partial def compileWhileStmt (condition : Absyn.Expr) (body : Absyn.Stmt) : GenM Code := do
    let condLabel ← freshLabel
    let bodyLabel ← freshLabel
    let endLabel ← freshLabel

    let condCode ← generateCondition condition bodyLabel endLabel
    let bodyCode ← compileStmt body

    let mut code := Code.empty
    code := code.emit (br condLabel)
    code := code.emit condLabel
    code := code ++ condCode
    code := code.emit bodyLabel
    code := code ++ bodyCode
    code := code.emit (br condLabel)
    code := code.emit endLabel
    pure code

  partial def compileBlockStmt (stmts : List Absyn.Stmt): GenM Code := do
    let mut code := Code.empty
    for s in stmts do
      let c ← compileStmt s
      code := code ++ c
    pure code

  partial def compileStmt (s : Absyn.Stmt) : GenM Code :=
    match s with
    | .assign target value => compileAssignStmt target value
    | .call name arguments => compileCallStmt name arguments
    | .if_ condition t e   => compileIfStmt condition t e
    | .while_ condition b  => compileWhileStmt condition b
    | .block stmts         => compileBlockStmt stmts
    | .empty               => pure Code.empty
end

def compileProcDef (d : Absyn.ProcDef): GenM IR.Function := do
  let s <- get
  let globalTable := s.globalTable

  match globalTable.lookup d.name with
  | .ok (.proc pe) =>
    set { s with localTable := pe.local_table }

    let params := pe.parameters.reverse.map convertParameterToLLVM |>.toArray

    let mut body : Code := Code.empty
    body := body.emit <| IR.Label.mk "entry" true

    body := body ++ (initializeParams pe.parameters.reverse).toArray
    body := body ++ (initializeVars d pe.local_table).toArray

    for s in d.body do
      let c ← compileStmt s
      body := body ++ c

    body := body.emit ret

    pure {
      name := ⟨d.name, false⟩
      type := IR.LLVMType.void
      parameters := params
      body := body
    }

  | _ => panic! "Internal Error: Could not lookup procedure entry"

def compileProgram (p : Absyn.Program) : GenM IR.Program := do
  let globTable := (← get).globalTable

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

  let funcs := (← procDefs.mapM (fun d => compileProcDef d)).toArray

  let decls : Array IR.Declaration :=
    (globTable.builtinProcedures.map (fun (procName, pe) =>
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

  let decls : Array IR.Declaration :=
    decls ++ #[
      ⟨⟨"__init_time", true⟩, #[]⟩,
      ⟨⟨"__sdl_init_screen", true⟩, #[]⟩,
      ⟨⟨"__sdl_event_loop", true⟩, #[]⟩
    ]

  pure {
    declarations := decls,
    functions := funcs.push main
  }

end CodeGenerator
