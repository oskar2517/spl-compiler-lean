namespace Absyn

inductive UnaryOperator where
  | minus
  deriving Repr

inductive Operator where
  | add
  | sub
  | mul
  | div
  | equ
  | neq
  | lst
  | lse
  | grt
  | gre
  | default
  deriving Repr

mutual
  inductive Expr where
    | binary_expression (be: BinaryExpression)
    | unary_expression (ue: UnaryExpression)
    | int_literal (i: Int)
    | variable_expression (ve: Variable)
    deriving Repr

  structure UnaryExpression where
    operator: UnaryOperator
    operand: Expr
    deriving Repr

  structure BinaryExpression where
    operator: Operator
    left: Expr
    right: Expr
    deriving Repr

  inductive Variable where
    | named_variable (nv: String)
    | array_access (aa: ArrayAccess)
    deriving Repr

  structure ArrayAccess where
    array: Variable
    index: Expr
    -- typ: Option ArrayType
    deriving Repr
end

structure AssignStatement where
  target: Variable
  value: Expr
  deriving Repr

structure CallStatement where
  name: String
  arguments: List Expr
  deriving Repr

mutual
  inductive Statement where
    | call_statement (cs: CallStatement)
    | assign_statement (as: AssignStatement)
    | if_statement (is: IfStatement)
    | emptyStatement
    | while_statement (ws: WhileStatement)
    | compound_statement (sl: List Statement)
    deriving Repr

  structure IfStatement where
    condition: Expr
    then_branch: Statement
    else_branch: Option Statement
    deriving Repr

  structure WhileStatement where
    condition: Expr
    body: Statement
    deriving Repr
end

mutual
  inductive TypeExpression where
    | array_type_expression (ate: ArrayTypeExpression)
    | named_typ_expression (nte: String)
    deriving Repr

  structure ArrayTypeExpression where
    array_size: Int
    base_type: TypeExpression
    deriving Repr
end

structure ParameterDefinition where
  name: String
  type_expression: TypeExpression
  is_reference: Bool
  deriving Repr

structure VariableDefinition where
  name: String
  type_expression: TypeExpression
  deriving Repr

structure ProcedureDefinition where
  name: String
  parameters: List ParameterDefinition
  body: List Statement
  variables: List VariableDefinition
  deriving Repr

structure TypeDefinition where
  name: String
  type_expression: TypeExpression
  deriving Repr

inductive GlobalDefinition where
  | procedure_definition (pd: ProcedureDefinition)
  | type_definition (td: TypeDefinition)
  deriving Repr

structure Program where
  definitions: List GlobalDefinition
  deriving Repr

inductive Token where
  | other
  | eq
  | ne
  | lt
  | gt
  | ge
  | le
  | plus
  | minus
  | star
  | slash
  deriving Repr

end Absyn
