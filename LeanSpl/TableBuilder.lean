import LeanSpl.Absyn
import LeanSpl.Table

namespace TableBuilder

abbrev ExceptTable := Except String Table.SymbolTable

private def typeFromTypeExpression (typeExpr : Absyn.TypeExpr) (globTable : Table.SymbolTable) : Except String Table.SplType := do
  match typeExpr with
  | .named nte =>
      match (← globTable.lookup nte) with
      | .type t => pure t.typ
      | _       => .error s!"{nte} is not a type"
  | .array size base => do
      let typ ← typeFromTypeExpression base globTable
      pure <| .arr ⟨typ, size⟩

private def enterParamDef (paramDef : Absyn.ParamDef) (locTable : Table.SymbolTable) (globTable : Table.SymbolTable) : ExceptTable := do
  let typ ← typeFromTypeExpression paramDef.type_expr globTable
  locTable.enter paramDef.name (.var ⟨typ, paramDef.is_ref⟩)

private def enterVarDef (varDef : Absyn.VarDef) (locTable : Table.SymbolTable) (globTable : Table.SymbolTable) : ExceptTable := do
  let typ ← typeFromTypeExpression varDef.type_expr globTable
  locTable.enter varDef.name (.var ⟨typ, false⟩)

private def enterProcDef (procDef : Absyn.ProcDef) (globTable: Table.SymbolTable) : ExceptTable := do
    let mut locTable := default
    let mut params := []
    for p in procDef.parameters do
        locTable <- enterParamDef p locTable globTable
        let typ <- typeFromTypeExpression p.type_expr globTable
        params := ⟨ p.name, typ, p.is_ref ⟩ :: params

    for v in procDef.variables do
        locTable <- enterVarDef v locTable globTable

    let entry := Table.Entry.proc ⟨ locTable, params, false ⟩

    globTable.enter procDef.name entry

private def enterTypeDef (typeDef: Absyn.TypeDef) (globTable : Table.SymbolTable): ExceptTable := do
    let typ <- typeFromTypeExpression typeDef.type_expr globTable
    let entry := Table.Entry.type ⟨ typ ⟩
    globTable.enter typeDef.name entry

private def enterGlobalDefinition (globDef: Absyn.GlobalDef) (globTable: Table.SymbolTable): ExceptTable :=
    match globDef with
    | Absyn.GlobalDef.procedure proc => enterProcDef proc globTable
    | Absyn.GlobalDef.type typ => enterTypeDef typ globTable

private def builtinProc (name : String) (params : List Table.Parameter) : String × Table.Entry :=
  (name, .proc ⟨⟨[]⟩, params, true⟩)

private def builtinTyp (name : String) (typ : Table.SplType) : String × Table.Entry :=
  (name, .type ⟨typ⟩)

def initTable : Table.SymbolTable :=
  ⟨[
    builtinProc "printi"   [⟨"i", .primitive .int, false⟩],
    builtinProc "printc"   [⟨"c", .primitive .int, false⟩],
    builtinProc "readi"    [⟨"i", .primitive .int, true⟩],
    builtinProc "readc"    [⟨"c", .primitive .int, true⟩],
    builtinProc "exit"     [],
    builtinProc "time"     [⟨"t", .primitive .int, true⟩],
    builtinProc "clearAll" [⟨"c", .primitive .int, false⟩],

    builtinProc "setPixel"
      [ ⟨"a", .primitive .int, false⟩
      , ⟨"b", .primitive .int, false⟩
      , ⟨"c", .primitive .int, false⟩
      ],

    builtinProc "drawLine"
      [ ⟨"a", .primitive .int, false⟩
      , ⟨"b", .primitive .int, false⟩
      , ⟨"c", .primitive .int, false⟩
      , ⟨"d", .primitive .int, false⟩
      , ⟨"e", .primitive .int, false⟩
      ],

    builtinProc "drawCircle"
      [ ⟨"a", .primitive .int, false⟩
      , ⟨"b", .primitive .int, false⟩
      , ⟨"c", .primitive .int, false⟩
      , ⟨"d", .primitive .int, false⟩
      ],

    builtinTyp "int" (.primitive .int)
  ]⟩

def buildSymbolTable (prog : Absyn.Program) : ExceptTable := do
    let mut table := initTable
    for definition in prog.definitions do
        table <- enterGlobalDefinition definition table

    .ok table

end TableBuilder
