import LeanSpl.Absyn
import LeanSpl.Table

namespace SemanticAnalysis

def ensure (b : Bool) (msg : String) : Except String Unit :=
  if b then .ok () else .error msg

mutual

  def varType (var: Absyn.Variable) (table: Table.SymbolTable) : Except String Table.SplType :=
    match var with
    | .named nv => do
      let e ← table.lookup nv

      match e with
      | .var ve => .ok ve.typ
      | _ => .error s!"{nv} is not a variable"

    | .index arr i => do
      let typ ← varType arr table
      let arrTyp ← match typ with
        | .arr a => .ok a
        | .primitive _ => .error "attempting to index non array"

      let indexTyp ← checkExpr i table

      let _ ← match indexTyp with
        | .primitive pt => match pt with
          | .bool => .error "index must be int, received bool"
          | .int => .ok ()
        | .arr _  => .error "index must be int, received array"

      .ok arrTyp.base

  def checkExpr (expr: Absyn.Expr) (table: Table.SymbolTable) : Except String Table.SplType :=
    match expr with
    | .bin op left right => do
      let leftTyp ← checkExpr left table
      let rightTyp ← checkExpr right table

      ensure (leftTyp == rightTyp) "operand type mismatch"

      .ok <| Absyn.BinOp.typ op

    | .un _ operand => do
      let operandTyp ← checkExpr operand table
      ensure (operandTyp == .primitive .int) "operand for unary Minus must be int"

      .ok <| .primitive .int

    | .int _ => .ok <| .primitive .int
    | .var v => varType v table

end

def checkAssignStmt
  (target: Absyn.Variable)
  (value: Absyn.Expr)
  (table: Table.SymbolTable)
  : Except String Unit := do

  let targetTyp ← varType target table
  let valueTyp ← checkExpr value table

  ensure (!(targetTyp matches .arr _)) "cannot assign to array"
  ensure (targetTyp == valueTyp) "type mismatch"

def checkCallStmt
  (name : String)
  (args: List Absyn.Expr)
  (table: Table.SymbolTable)
  (global: Table.SymbolTable)
  : Except String Unit := do

  let e ← global.lookup name

  let proc ← match e with
  | .proc pe => .ok pe
  | _ => .error s!"{name} is not a procedure"

  ensure (args.length == proc.parameters.length) s!"{name}: number of arguments provided does not match the number of required parameters"

  for (p, arg) in proc.parameters.zip args.reverse do
    let argTyp ← checkExpr arg table

    ensure (argTyp == p.typ) s!"{name}: argument type mismatch"

    if p.is_ref then
      ensure (arg matches .var _) "Argument to a reference parameter must be variable"

mutual
  partial def checkWhileStmt
    (cond: Absyn.Expr)
    (body: Absyn.Stmt)
    (table: Table.SymbolTable)
    (global: Table.SymbolTable)
    : Except String Unit := do

    let type ← checkExpr cond table
    let _ ← match type with
      | .primitive p => match p with
        | .bool => .ok ()
        | _ => .error "if condition must be Boolean, received int"
      | _  => .error "if condition must be boolean, received array"

    let _ ← checkStmt body table global


  partial def checkIfStmt
    (cond: Absyn.Expr)
    (thenBranch: Absyn.Stmt)
    (elseBranch: Option Absyn.Stmt)
    (table: Table.SymbolTable)
    (global: Table.SymbolTable)
    : Except String Unit := do

    let typ ← checkExpr cond table

    match typ with
      | .primitive p => match p with
        | .bool => .ok ()
        | _ => .error "if condition must be Boolean, received int"
      | _  => .error "if condition must be boolean, received array"

    checkStmt thenBranch table global
    match elseBranch with
      | some s => checkStmt s table global
      | none => .ok ()

  partial def checkStmt (s: Absyn.Stmt) (table: Table.SymbolTable) (global: Table.SymbolTable): Except String Unit :=
    match s with
      | .assign t v => checkAssignStmt t v table
      | .block b => checkBlock b table global
      | .call n args => checkCallStmt n args table global
      | .empty => .ok ()
      | .if_ cond t e => checkIfStmt cond t e table global
      | .while_ cond b => checkWhileStmt cond b table global

  partial def checkBlock
    (stmts: List Absyn.Stmt)
    (table: Table.SymbolTable)
    (global: Table.SymbolTable)
    : Except String Unit := do

    for s in stmts do
      checkStmt s table global

end

def checkProcDef (d: Absyn.ProcDef) (table: Table.SymbolTable) : Except String Unit := do
  let e ← table.lookup d.name

  let proc ← match e with
  | .proc pe => .ok pe
  | _ => unreachable!

  for s in d.body do
    checkStmt s proc.local_table table

def checkGlobalDef (d: Absyn.GlobalDef) (table: Table.SymbolTable) : Except String Unit :=
  match d with
    | .procedure pd => checkProcDef pd table
    | .type _ => .ok ()

def checkProgram (p: Absyn.Program) (table: Table.SymbolTable) : Except String Unit := do
  for d in p.definitions do
    let _ ← checkGlobalDef d table

end SemanticAnalysis
