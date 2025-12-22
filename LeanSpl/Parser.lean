import Std.Internal.Parsec.String
import LeanSpl.Absyn

open Std.Internal.Parsec
open Std.Internal.Parsec.String

namespace Parser
open Absyn

abbrev Parser (α : Type) := Std.Internal.Parsec.String.Parser α

mutual
  partial def comment : Parser Unit := do
    tag "//"
    let _ ← manyChars <| satisfy fun c => c != '\n'
    pure ()

  partial def whitespace : Parser Unit := do
    ws <|> comment

  partial def tag (s: String) : Parser Unit := do
    whitespace
    skipString s
    whitespace
end

def ident : Parser String := do
  whitespace
  let first ← asciiLetter <|> pchar '_'
  let later ← manyChars <| asciiLetter <|> pchar '_' <|> digit
  pure <| first.toString ++ later

def character : Parser Int := do
  skipChar '\''
  let char ← take 1
  skipChar '\''
  pure <| char.front.toNat

def integer : Parser Int := do
  let digitsStr ← many1Chars digit
  let n := digitsStr.toInt!
  pure n

def hexNum : Parser Int := do
  skipString "0x"
  let hex ← many1 hexDigit
  let hex ← pure <| hex.map (fun d => if d.isDigit then d.toNat else d.toLower.toNat - 'a'.toNat + 58)
  pure <| hex.foldl (fun acc d => (acc - 3) * 16 + Int.ofNat d) 0

def intlit : Parser Int := do
  whitespace
  let value ← hexNum <|> integer <|> character
  whitespace
  pure value

def namedTypeExpr : Parser TypeExpression := do
  let id ← ident
  pure <| TypeExpression.named_typ_expression id

mutual

partial def arrayTypeExpr : Parser TypeExpression := do
  tag "array"
  tag "["
  let len ← intlit
  tag "]"
  tag "of"
  let te ← typeExpr
  pure <| TypeExpression.array_type_expression <| ArrayTypeExpression.mk len te

partial def typeExpr : Parser TypeExpression := do
  let te ← arrayTypeExpr <|> namedTypeExpr
  pure te

end

def emptyParamList : Parser (List ParameterDefinition) := do
  pure []

def ref_param : Parser ParameterDefinition := do
  tag "ref"
  let id ← ident
  tag ":"
  let te ← typeExpr
  pure <| ParameterDefinition.mk id te true

def non_ref_param : Parser ParameterDefinition := do
  let id ← ident
  tag ":"
  let te ← typeExpr
  pure <| ParameterDefinition.mk id te false

def parameter : Parser (List ParameterDefinition) := do
  (fun x => [x]) <$> (ref_param <|> non_ref_param)

mutual

  partial def moreThanOneParameter : Parser (List ParameterDefinition) := do
    let param ← parameter
    tag ","
    let tail ← nonEmptyParamList
    pure <| param ++ tail

  partial def nonEmptyParamList : Parser (List ParameterDefinition) := do
    attempt moreThanOneParameter <|> parameter

end

def paramList : Parser (List ParameterDefinition) := do
  nonEmptyParamList <|> emptyParamList

def eq : Parser Token := do
  tag "="
  pure Token.eq

def ne : Parser Token := do
  tag "#"
  pure Token.ne

def lt : Parser Token := do
  tag "<"
  pure Token.lt

def gt : Parser Token := do
  tag ">"
  pure Token.gt

def le : Parser Token := do
  tag "<="
  pure Token.le

def ge : Parser Token := do
  tag ">="
  pure Token.ge

def plus : Parser Token := do
  tag "+"
  pure Token.plus

def minus : Parser Token := do
  tag "-"
  pure Token.minus

def star : Parser Token := do
  tag "*"
  pure Token.star

def slash : Parser Token := do
  tag "/"
  pure Token.slash

def intlitExpr : Parser Expr := do
  let i ← intlit
  pure <| Expr.int_literal i

def namedVariable : Parser Variable := do
  let id ← ident
  pure <| Variable.named_variable id

mutual

  partial def variableParser : Parser Variable := do
    let base ← namedVariable
    let arr ← many (attempt do
      tag "["
      let ex ← expr
      tag "]"
      pure ex
    )
    pure <| arr.foldl (fun var e => Variable.array_access <| ArrayAccess.mk var e) base

  partial def variableExpr : Parser Expr := do
    let var ← variableParser
    pure <| Expr.variable_expression var

  partial def parenthesisExpr : Parser Expr := do
    tag "("
    let ex ← expr
    tag ")"
    pure ex

  partial def expr4 : Parser Expr := do
    intlitExpr <|> variableExpr <|> parenthesisExpr

  partial def expr3 : Parser Expr := (do
    let _ ← minus
    let ex ← expr3
    pure <| Expr.unary_expression <| UnaryExpression.mk UnaryOperator.minus ex)
    <|>
    expr4

  partial def expr2 : Parser Expr := do
    let left ← expr3
    (do
    let op ← star <|> slash
    let right ← expr2
    let op ← pure <| match op with
      | Absyn.Token.star => Operator.mul
      | Absyn.Token.slash => Operator.div
      | _ => Operator.default
    pure <| Expr.binary_expression <| BinaryExpression.mk op left right)
    <|>
    pure left

  partial def expr1 : Parser Expr := do
    let left ← expr2
    (do
    let op ← plus <|> minus
    let right ← expr1
    let op ← pure <| match op with
      | Absyn.Token.plus => Operator.add
      | Absyn.Token.minus => Operator.sub
      | _ => Operator.default
    pure <| Expr.binary_expression <| BinaryExpression.mk op left right)
    <|>
    pure left

  partial def expr0 : Parser Expr := do
    let left ← expr1
    (do
    let op ← lt <|> le <|> gt <|> ge <|> eq <|> ne
    let right ← expr0
    let op ← pure <| match op with
      | Absyn.Token.eq => Operator.equ
      | Absyn.Token.ne => Operator.neq
      | Absyn.Token.le => Operator.lse
      | Absyn.Token.lt => Operator.lst
      | Absyn.Token.ge => Operator.gre
      | Absyn.Token.gt => Operator.grt
      | _ => Operator.default
    pure <| Expr.binary_expression <| BinaryExpression.mk op left right)
    <|>
    pure left

  partial def expr : Parser Expr := do
      expr0

end

mutual
  partial def moreThanOneArgument : Parser (List Expr) := do
    let ex ← (fun x => [x]) <$> expr
    tag ","
    let list ← nonEmptyArgumentList
    pure <| ex ++ list


  partial def nonEmptyArgumentList : Parser (List Expr) := do
    attempt moreThanOneArgument <|> (fun x => [x]) <$> expr

end

def emptyArgumentList : Parser (List Expr) :=
  pure []

def argumentList : Parser (List Expr) := do
  nonEmptyArgumentList <|> emptyArgumentList

def emptyStatement : Parser Statement := do
  tag ";"
  pure Statement.emptyStatement

def callStatement : Parser Statement := do
  let id ← ident
  tag "("
  let args ← argumentList
  tag ")"
  tag ";"
  pure <| Statement.call_statement <| CallStatement.mk id args


mutual
  partial def ifStatementWithElse : Parser Statement := do
    tag "if"
    tag "("
    let ex ← expr
    tag ")"
    let st ← statement
    tag "else"
    let elseSt ← statement
    pure <| Statement.if_statement <| IfStatement.mk ex st (some elseSt)

  partial def ifStatementWithoutElse : Parser Statement := do
    tag "if"
    tag "("
    let ex ← expr
    tag ")"
    let st ← statement
    pure <| Statement.if_statement <| IfStatement.mk ex st none

  partial def ifStatement : Parser Statement := do
    attempt ifStatementWithElse <|> ifStatementWithoutElse

  partial def assignStatement : Parser Statement := do
    let var ← variableParser
    tag ":="
    let ex ← expr
    tag ";"
    pure <| Statement.assign_statement <| AssignStatement.mk var ex

  partial def whileStatement : Parser Statement := do
    tag "while"
    tag "("
    let ex ← expr
    tag ")"
    let st ← statement
    pure <| Statement.while_statement <| WhileStatement.mk ex st

  partial def compoundStatement : Parser Statement := do
    tag "{"
    let st ← many statement
    tag "}"
    pure <| Statement.compound_statement st.toList

  partial def statement : Parser Statement := do
    emptyStatement <|> ifStatement <|> attempt assignStatement <|> whileStatement <|> compoundStatement <|> callStatement

end

def variableDef : Parser VariableDefinition := do
  tag "var"
  let name ← ident
  tag ":"
  let te ← typeExpr
  tag ";"
  pure <| VariableDefinition.mk name te

def procDef : Parser ProcedureDefinition := do
  tag "proc"
  let name ← ident
  tag "("
  let params ← paramList
  tag ")"
  tag "{"
  let vars ← many variableDef
  let statements ← many statement
  tag "}"
  pure <| ProcedureDefinition.mk name params statements.toList vars.toList

def typeDef : Parser TypeDefinition := do
  ws
  tag "type"
  let id ← ident
  tag "="
  let typeExpr ← typeExpr
  tag ";"
  pure <| TypeDefinition.mk id typeExpr

def globalDef : Parser GlobalDefinition := do
  (GlobalDefinition.type_definition <$> typeDef)
  <|>
  (GlobalDefinition.procedure_definition <$> procDef)

partial def globalDefList : Parser (List GlobalDefinition) := do
  let defs ← many globalDef
  eof
  pure defs.toList

def newline : Parser Token := do
  let _ ← pstring "'\\n'"
  pure <| Token.intlit 10

def parse (s: String) : Except String Expr :=
  Parser.run expr1 s

end Parser
