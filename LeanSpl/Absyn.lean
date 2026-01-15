import LeanSpl.Table

namespace Absyn

inductive UnOp where
  | neg
  deriving Repr, DecidableEq

inductive BinOp where
  | add | sub | mul | div
  | eq | ne | lt | le | gt | ge
   deriving Repr, DecidableEq

def BinOp.typ : BinOp → Table.SplType
  | .add | .sub | .mul | .div         => .primitive .int
  | .eq | .ne | .lt | .le | .gt | .ge => .primitive .bool

mutual
  inductive Expr : Type where
    | bin (op : BinOp) (left right : Expr)
    | un  (op : UnOp) (operand : Expr)
    | int (i : Int)
    | var (v : Variable)
    deriving Repr

  inductive Variable : Type where
    | named (name : String)
    | index (array : Variable) (index: Expr)
    deriving Repr

  inductive Stmt : Type where
    | call   (name : String) (arguments : List Expr)
    | assign (target : Variable) (value : Expr)
    | if_    (condition : Expr) (then_branch : Stmt) (else_branch : Option Stmt)
    | while_ (condition : Expr) (body : Stmt)
    | block  (stmts : List Stmt)
    | empty
    deriving Repr
end

inductive TypeExpr where
  | array (size : Nat) (base_type : TypeExpr)
  | named (name : String)
  deriving Repr

structure ParamDef where
  name: String
  type_expr: TypeExpr
  is_ref: Bool
  deriving Repr

structure VarDef where
  name: String
  type_expr: TypeExpr
  deriving Repr

structure ProcDef where
  name: String
  parameters: List ParamDef
  variables: List VarDef
  body: List Stmt
  deriving Repr

structure TypeDef where
  name: String
  type_expr: TypeExpr
  deriving Repr

inductive GlobalDef where
  | procedure (d: ProcDef)
  | type (d: TypeDef)
  deriving Repr

structure Program where
  definitions: List GlobalDef
  deriving Repr

end Absyn
