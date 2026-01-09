import LeanSpl.Absyn
import LeanSpl.Table

namespace SemanticAnalysis
mutual
  def varType (var: Absyn.Variable) (table: Table.SymbolTable) : Except String Table.SplType :=
    match var with
      | Absyn.Variable.named nv => match Table.SymbolTable.lookup table none nv with
        | some e => match e with
          | Table.Entry.var ve => pure ve.typ
          | _ => Except.error s!"{nv} is not a variable"
        | none => Except.error s! "{nv} not found"
      | Absyn.Variable.index arr i => do
        let arr <- varType arr table
        let arrType <- match arr with
          | Table.SplType.arr a => pure a
          | Table.SplType.primitive _ => Except.error "attempting to index non array"

        let indexType <- checkExpr i table

        let _ <- match indexType with
          | Table.SplType.primitive pt => match pt with
            | Table.PrimitiveType.bool => Except.error "index must be int, received bool"
            | Table.PrimitiveType.int => pure ()
          | Table.SplType.arr _  => Except.error "index must be int, received array"

        pure <| arrType.base

  def checkExpr (expr: Absyn.Expr) (table: Table.SymbolTable) : Except String Table.SplType :=
    match expr with
      | Absyn.Expr.bin op left right => do
          let leftType <- checkExpr left table
          let rightType <- checkExpr right table

          let _ <- if leftType != rightType then Except.error s!"operand type mismatch"

          pure <| Absyn.BinOp.operatorType op
      | Absyn.Expr.un _ operand => do
          let operandType <- checkExpr operand table
          if operandType != (Table.SplType.primitive Table.PrimitiveType.int) then Except.error "operand for unary Minus must be int"

          pure <| Table.SplType.primitive Table.PrimitiveType.int
      | Absyn.Expr.int _ => pure <| Table.SplType.primitive Table.PrimitiveType.int
      | Absyn.Expr.var v => varType v table
end

def checkAssignStmt (target: Absyn.Variable) (value: Absyn.Expr) (table: Table.SymbolTable) : Except String Unit := do
  let targetType <- varType target table
  let valueType <- checkExpr value table

  let _ <- if Table.SplType.isArray targetType || targetType != valueType then Except.error "target type does not match value type or you are trying to assign to an array"


def checkCallStmt (name : String) (args: List Absyn.Expr) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
  let proc <- match Table.SymbolTable.lookup global none name with
    | some e => match e with
      | Table.Entry.proc pe => pure pe
      | _ => Except.error s!"{name} is not a procedure"
    | none => Except.error s!"callStatement: {name} not found"

  let _ <- if args.length != proc.parameters.length then Except.error s!"{name}: number of arguments provided does not match the number of required parameters"

  let _ <- for (p, arg) in proc.parameters.zip args.reverse do
    let argType <- checkExpr arg table
    let _ <- match argType == p.typ with
    | true => pure ()
    | false => Except.error s!"{name}: argument type mismatch"

    let _ <- if p.is_ref && ¬ Absyn.Expr.isVariable arg then
      Except.error "Argument to a reference parameter must be variable"

mutual
  partial def checkWhileStmt (cond: Absyn.Expr) (body: Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
    let type <- checkExpr cond table
    let _ <- match type with
      | Table.SplType.primitive p => match p with
        | Table.PrimitiveType.bool => pure ()
        | _ => Except.error "if condition must be Boolean, received int"
      | _  => Except.error "if condition must be boolean, received array"

    let _ <- checkStatement body table global


  partial def checkIfStmt (cond: Absyn.Expr) (thenBranch: Absyn.Stmt) (elseBranch: Option Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
    let type <- checkExpr cond table

    let _ <- match type with
      | Table.SplType.primitive p => match p with
        | Table.PrimitiveType.bool => pure ()
        | _ => Except.error "if condition must be Boolean, received int"
      | _  => Except.error "if condition must be boolean, received array"

    let _ <- checkStatement thenBranch table global
    let _ <- match elseBranch with
      | some s => checkStatement s table global
      | none => pure ()

  partial def checkStatement (s: Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit :=
    match s with
      | Absyn.Stmt.assign t v => checkAssignStmt t v table
      | Absyn.Stmt.block b => checkBlock b table global
      | Absyn.Stmt.call n args => checkCallStmt n args table global
      | Absyn.Stmt.empty => pure ()
      | Absyn.Stmt.if_ cond t e => checkIfStmt cond t e table global
      | Absyn.Stmt.while_ cond b => checkWhileStmt cond b table global

  partial def checkBlock (stmts: List Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
    for s in stmts do
      let _ <- checkStatement s table global

end

def checkProcDef (d: Absyn.ProcDef) (table: Table.SymbolTable) : Except String Unit := do
  let ent <- match Table.SymbolTable.lookup table none d.name with
    | some ent => match ent with
      | Table.Entry.proc pe => pure pe
      | _ => Except.error "unreachable"
    | none => Except.error "unreachable"

  for s in d.body do
    let _ <- checkStatement s ent.local_table table

def checkGlobalDefinition (d: Absyn.GlobalDef) (table: Table.SymbolTable) : Except String Unit :=
  match d with
    | Absyn.GlobalDef.procedure pd => checkProcDef pd table
    | Absyn.GlobalDef.type _ => pure ()

def checkProgram (p: Absyn.Program) (table: Table.SymbolTable) : Except String Unit := do
  for definition in p.definitions do
    let _ <- checkGlobalDefinition definition table

end SemanticAnalysis
