import LeanSpl.Absyn
import LeanSpl.Table

namespace SemanticAnalysis
mutual
  def varType (var: Absyn.Variable) (table: Table.SymbolTable) : Except String Table.SplType :=
    match var with
      | .named nv => match Table.SymbolTable.lookup table nv with
        | some e => match e with
          | .var ve => pure ve.typ
          | _ => .error s!"{nv} is not a variable"
        | none => .error s! "{nv} not found"
      | .index arr i => do
        let arr ← varType arr table
        let arrType ← match arr with
          | .arr a => pure a
          | .primitive _ => .error "attempting to index non array"

        let indexType ← checkExpr i table

        let _ ← match indexType with
          | .primitive pt => match pt with
            | .bool => .error "index must be int, received bool"
            | .int => pure ()
          | .arr _  => .error "index must be int, received array"

        pure <| arrType.base

  def checkExpr (expr: Absyn.Expr) (table: Table.SymbolTable) : Except String Table.SplType :=
    match expr with
      | .bin op left right => do
          let leftType ← checkExpr left table
          let rightType ← checkExpr right table

          let _ ← if leftType != rightType then .error s!"operand type mismatch"

          pure <| Absyn.BinOp.typ op
      | .un _ operand => do
          let operandType ← checkExpr operand table
          if operandType != (.primitive .int) then .error "operand for unary Minus must be int"

          pure <| .primitive .int
      | .int _ => pure <| .primitive .int
      | .var v => varType v table
end

def checkAssignStmt (target: Absyn.Variable) (value: Absyn.Expr) (table: Table.SymbolTable) : Except String Unit := do
  let targetType ← varType target table
  let valueType ← checkExpr value table

  let _ ← if targetType matches .arr _ || targetType != valueType then .error "target type does not match value type or you are trying to assign to an array"


def checkCallStmt (name : String) (args: List Absyn.Expr) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
  let proc ← match Table.SymbolTable.lookup global name with
    | some e => match e with
      | .proc pe => pure pe
      | _ => .error s!"{name} is not a procedure"
    | none => .error s!"callStatement: {name} not found"

  let _ ← if args.length != proc.parameters.length then .error s!"{name}: number of arguments provided does not match the number of required parameters"

  let _ ← for (p, arg) in proc.parameters.zip args.reverse do
    let argType ← checkExpr arg table
    let _ ← match argType == p.typ with
    | true => pure ()
    | false => .error s!"{name}: argument type mismatch"

    let _ ← if p.is_ref && !(arg matches .var _) then
      .error "Argument to a reference parameter must be variable"

mutual
  partial def checkWhileStmt (cond: Absyn.Expr) (body: Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
    let type ← checkExpr cond table
    let _ ← match type with
      | .primitive p => match p with
        | .bool => pure ()
        | _ => .error "if condition must be Boolean, received int"
      | _  => .error "if condition must be boolean, received array"

    let _ ← checkStatement body table global


  partial def checkIfStmt (cond: Absyn.Expr) (thenBranch: Absyn.Stmt) (elseBranch: Option Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
    let type ← checkExpr cond table

    let _ ← match type with
      | .primitive p => match p with
        | .bool => pure ()
        | _ => .error "if condition must be Boolean, received int"
      | _  => .error "if condition must be boolean, received array"

    let _ ← checkStatement thenBranch table global
    let _ ← match elseBranch with
      | some s => checkStatement s table global
      | none => pure ()

  partial def checkStatement (s: Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit :=
    match s with
      | .assign t v => checkAssignStmt t v table
      | .block b => checkBlock b table global
      | .call n args => checkCallStmt n args table global
      | .empty => pure ()
      | .if_ cond t e => checkIfStmt cond t e table global
      | .while_ cond b => checkWhileStmt cond b table global

  partial def checkBlock (stmts: List Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit := do
    for s in stmts do
      let _ ← checkStatement s table global

end

def checkProcDef (d: Absyn.ProcDef) (table: Table.SymbolTable) : Except String Unit := do
  let ent ← match Table.SymbolTable.lookup table d.name with
    | some ent => match ent with
      | .proc pe => pure pe
      | _ => .error "unreachable"
    | none => .error "unreachable"

  for s in d.body do
    let _ ← checkStatement s ent.local_table table

def checkGlobalDefinition (d: Absyn.GlobalDef) (table: Table.SymbolTable) : Except String Unit :=
  match d with
    | .procedure pd => checkProcDef pd table
    | .type _ => pure ()

def checkProgram (p: Absyn.Program) (table: Table.SymbolTable) : Except String Unit := do
  for definition in p.definitions do
    let _ ← checkGlobalDefinition definition table

end SemanticAnalysis
