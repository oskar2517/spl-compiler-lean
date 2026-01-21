import Std.Data.TreeMap

namespace Table

mutual
  structure ArrayType where
    base : SplType
    size : Nat
    deriving Repr, BEq

  inductive PrimitiveType where
    | int
    | bool
    deriving Repr, BEq

  inductive SplType where
    | arr       (a : ArrayType)
    | primitive (p : PrimitiveType)
    deriving Repr, BEq

  structure Parameter where
    name   : String
    typ    : SplType
    is_ref : Bool
    deriving Repr

  structure ProcedureEntry where
    local_table : SymbolTable
    parameters  : List Parameter
    is_builtin  : Bool
    deriving Repr

  structure VariableEntry where
    typ    : SplType
    is_ref : Bool
    deriving Repr

  structure TypeEntry where
    typ : SplType
    deriving Repr

  inductive Entry where
    | proc (e : ProcedureEntry)
    | var  (e : VariableEntry)
    | type (e : TypeEntry)
    deriving Repr

  structure SymbolTable : Type where
    entries: List (String × Entry)
    deriving Repr, Inhabited
end

namespace SymbolTable

  def contains (table : SymbolTable) (name : String) : Bool :=
    table.entries.any (fun (n, _) => n == name)

  def enter (table : SymbolTable) (name : String) (entry : Entry) : Except String SymbolTable := do
    if table.contains name then
      .error s!"{name} already exists"
    else
      .ok ⟨(name, entry) :: table.entries⟩

  def lookup (table : SymbolTable) (name : String) : Except String Entry :=
    match table.entries.find? (fun (n, _) => n == name) with
    | some (_, e) => .ok e
    | none        => .error s!"{name} not defined"

  def builtinProcedures (t : Table.SymbolTable) : List (String × Table.ProcedureEntry) :=
    t.entries.filterMap (fun (name, entry) =>
      match entry with
      | .proc pe =>
          if pe.is_builtin then some (name, pe) else none
      | _ => none)

end SymbolTable

end Table
