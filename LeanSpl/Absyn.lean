namespace Absyn

inductive UnaryOperator where
  | minus

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

mutual
  inductive Expr where
    | binary_expression (be: BinaryExpression)
    | unary_expression (ue: UnaryExpression)
    | int_literal (i: Int)
    | variable_expression (ve: Variable)
    --deriving Repr
  structure UnaryExpression where
    operator: UnaryOperator
    operand: Expr

  structure BinaryExpression where
    operator: Operator
    left: Expr
    right: Expr
end

structure AssignStatement where
  target: Variable
  value: Expr

structure CallStatement where
  name: String
  arguments: List Expr

mutual
  inductive Statement where
    | call_statement (cs: CallStatement)
    | assign_statement (as: AssignStatement)
    | if_statement (is: IfStatement)
    | emptyStatement
    | while_statement (ws: WhileStatement)
    | compound_statement (sl: List Statement)

  structure IfStatement where
    condition: Expr
    then_branch: Statement
    else_branch: Option Statement

  structure WhileStatement where
    condition: Expr
    body: Statement
end

structure ParameterDefinition where
  name: String
  type_expression: TypeExpression
  is_reference: Bool

structure VariableDefinition where
  name: String
  type_expression: TypeExpression

structure ProcedureDefinition where
  name: String
  parameters: List ParameterDefinition
  body: List Statement
  varaibles: List VariableDefinition

structure TypeDefinition where
  name: String
  type_expression: TypeExpression

inductive GlobalDefinition where
  | procedure_definition (pd: ProcedureDefinition)
  | type_definition (td: TypeDefinition)

mutual
  inductive Variable where
    | named_variable (nv: String)
    | array_access (aa: ArrayAccess)

  structure ArrayAccess where
    array: Variable
    index: Expr
    typ: Option ArrayType
end

mutual
  inductive TypeExpression where
    | array_type_expression (ate: ArrayTypeExpression)
    | named_typ_expression (nte: String)

  structure ArrayTypeExpression where
    array_size: Nat
    base_type: TypeExpression
end

structure Program where
  definitions: List GlobalDefinition

end Absyn
