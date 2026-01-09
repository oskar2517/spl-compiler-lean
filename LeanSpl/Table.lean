import Std.Data.TreeMap

open Std.TreeMap
namespace Table

mutual
  structure ArrayType where
    base: SplType
    size: Nat
    deriving Repr, BEq

  inductive PrimitiveType where
    | int
    | bool
    deriving Repr, BEq

  inductive SplType where
    | arr (a: ArrayType)
    | primitive (p: PrimitiveType)
    deriving Repr, BEq

  structure Parameter where
    name: String
    typ: SplType
    is_ref: Bool
    deriving Repr

  structure ProcedureEntry where
    local_table: SymbolTable
    parameters: List Parameter
    deriving Repr

  structure VariableEntry where
    typ: SplType
    is_ref: Bool
    deriving Repr

  structure TypeEntry where
    typ: SplType
    deriving Repr

  inductive Entry where
    | proc (e: ProcedureEntry)
    | var (e: VariableEntry)
    | type (e: TypeEntry)
    deriving Repr

  structure SymbolTable : Type where
    entries: List (String × Entry)
    deriving Repr
end

namespace SymbolTable

  def enter (table : SymbolTable) (name : String) (entry : Entry) : Except String SymbolTable := do
    let mut ent <- pure (name, entry)
    for e in table.entries do
      if e.fst = name then
        ent <- Except.error s!"{name} already exists"

    pure ⟨ ent :: table.entries ⟩

  def lookup (table : SymbolTable) (upperLevel : Option SymbolTable) (name : String) : Option Entry := do
    match table.entries.find? (fun e => e.fst == name) with
      | some e => pure e.snd
      | none => match upperLevel with
        | some global => match global.entries.find? (fun e => e.fst == name) with
          | some e => pure e.snd
          | none => none
        | none => none


end SymbolTable

namespace SplType

  def isArray (var: SplType) : Bool :=
    match var with
      | SplType.arr _ => true
      | SplType.primitive _ => false

end SplType

end Table
