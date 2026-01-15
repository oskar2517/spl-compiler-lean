import LeanSpl.Absyn
import LeanSpl.Table

namespace TableBuilder

def typeFromTypeExpression (te : Absyn.TypeExpr) (table : Table.SymbolTable): Except String Table.SplType :=
    match te with
        | Absyn.TypeExpr.named nte => match Table.SymbolTable.lookup table nte with
            | some t => match t with
                | Table.Entry.type t => pure t.typ
                | _ => .error s!"{nte} is not a type"
            | none => .error s!"{nte} not found"
        | Absyn.TypeExpr.array size base => match typeFromTypeExpression base table with
            | .ok typ => pure <| Table.SplType.arr ⟨ typ, size ⟩
            | .error e => Except.error e


def enterParamDef (param : Absyn.ParamDef) (table : Table.SymbolTable) (global : Table.SymbolTable) : Except String Table.SymbolTable := do
    let typ <- typeFromTypeExpression param.type_expr global
    let entry := Table.Entry.var ⟨ typ, param.is_ref ⟩
    Table.SymbolTable.enter table param.name entry

def enterVarDef (var : Absyn.VarDef) (table : Table.SymbolTable) (global : Table.SymbolTable) : Except String Table.SymbolTable := do
    let typ <- typeFromTypeExpression var.type_expr global
    let entry := Table.Entry.var ⟨ typ, false ⟩
    Table.SymbolTable.enter table var.name entry

def enterProcDef (proc : Absyn.ProcDef) (table: Table.SymbolTable) : Except String Table.SymbolTable := do
    let mut localTable := ⟨ [] ⟩
    let mut params := []
    for param in proc.parameters do
        localTable <- enterParamDef param localTable table
        let typ <- typeFromTypeExpression param.type_expr table
        params := ⟨ param.name, typ, param.is_ref ⟩ :: params

    for var in proc.variables do
        localTable <- enterVarDef var localTable table

    let entry := Table.Entry.proc ⟨ localTable, params, false ⟩

    Table.SymbolTable.enter table proc.name entry

def enterTypeDef (typ: Absyn.TypeDef) (table : Table.SymbolTable): Except String Table.SymbolTable := do
    let splTyp <- typeFromTypeExpression typ.type_expr table
    let entry := Table.Entry.type ⟨ splTyp ⟩
    Table.SymbolTable.enter table typ.name entry

def enterGlobalDefinition (definition: Absyn.GlobalDef) (table: Table.SymbolTable): Except String Table.SymbolTable :=
    match definition with
        | Absyn.GlobalDef.procedure proc => enterProcDef proc table
        | Absyn.GlobalDef.type typ => enterTypeDef typ table


def initTable : Table.SymbolTable :=
    ⟨ [
        ("printi", Table.Entry.proc ⟨ ⟨ [] ⟩, [⟨ "i", Table.SplType.primitive Table.PrimitiveType.int, false ⟩], true ⟩),
        ("printc", Table.Entry.proc ⟨ ⟨ [] ⟩, [⟨ "c", Table.SplType.primitive Table.PrimitiveType.int, false ⟩], true ⟩),
        ("readi", Table.Entry.proc ⟨ ⟨ [] ⟩, [⟨ "i", Table.SplType.primitive Table.PrimitiveType.int, true ⟩], true ⟩),
        ("readc", Table.Entry.proc ⟨ ⟨ [] ⟩, [⟨ "c", Table.SplType.primitive Table.PrimitiveType.int, true ⟩], true ⟩),
        ("exit", Table.Entry.proc ⟨ ⟨ [] ⟩, [], true ⟩),
        ("time", Table.Entry.proc ⟨ ⟨ [] ⟩, [⟨ "t", Table.SplType.primitive Table.PrimitiveType.int, true ⟩], true ⟩),
        ("clearAll", Table.Entry.proc ⟨ ⟨ [] ⟩, [⟨ "c", Table.SplType.primitive Table.PrimitiveType.int, false ⟩], true ⟩),
        ("setPixel", Table.Entry.proc ⟨ ⟨ [] ⟩, [
            ⟨ "a", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "b", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "c", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
        ], true ⟩),
        ("drawLine", Table.Entry.proc ⟨ ⟨ [] ⟩, [
            ⟨ "a", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "b", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "c", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "d", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "e", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
        ], true ⟩),
        ("drawCircle", Table.Entry.proc ⟨ ⟨ [] ⟩, [
            ⟨ "a", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "b", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "c", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
            ⟨ "d", Table.SplType.primitive Table.PrimitiveType.int, false ⟩,
        ], true⟩),
        ("int", Table.Entry.type ⟨ Table.SplType.primitive Table.PrimitiveType.int  ⟩ )
    ] ⟩

def buildSymbolTable (p : Absyn.Program) : Except String Table.SymbolTable := do
    let mut table := initTable
    for definition in p.definitions do
        table <- enterGlobalDefinition definition table

    pure table

end TableBuilder
