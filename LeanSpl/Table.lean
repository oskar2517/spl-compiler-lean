import Std.Data.TreeMap

open Std.TreeMap
namespace Table

mutual
  structure ArrayType where
    base: SplType
    size: Nat
    deriving Repr

  inductive PrimitiveType where
    | int
    | bool

  inductive SplType where
    | arr (a: ArrayType)
    | primitive (p: PrimitiveType)
    deriving Repr

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
    upper_lvl: Option SymbolTable
    deriving Repr
end



end Table
