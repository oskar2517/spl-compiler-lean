import Std.Internal.Parsec.String
import LeanSpl.Absyn

open Std.Internal.Parsec
open Std.Internal.Parsec.String

namespace Parser
open Absyn

abbrev Parser (α : Type) := Std.Internal.Parsec.String.Parser α

def integer : Parser Expr := do
  ws
  let neg ←
    (skipChar '-' *> pure true)
    <|> pure false

  let digitsStr ← many1Chars digit
  let n := digitsStr.toInt!
  let n := if neg then -n else n
  pure <| Expr.int_literal n

mutual

  partial def expr : Parser Expr := do
    let left ← term
    expr' left

  partial def expr' (left : Expr) : Parser Expr := do
    ws
    (do
      skipChar '+'
      let right ← term
      expr' (Expr.binary_expression (BinaryExpression.mk Operator.add left right)))
    <|>
    (do
      skipChar '-'
      let right ← term
      expr' (Expr.binary_expression (BinaryExpression.mk Operator.sub left right)))
    <|>
    pure left

  partial def term : Parser Expr := do
    let left ← factor
    term' left

  partial def term' (left : Expr) : Parser Expr := do
    ws
    (do
      skipChar '*'
      let right ← factor
      term' (Expr.binary_expression (BinaryExpression.mk Operator.mul left right)))
    <|>
    (do
      skipChar '/'
      let right ← factor
      term' (Expr.binary_expression (BinaryExpression.mk Operator.div left right)))
    <|>
    pure left

  partial def factor : Parser Expr := do
    ws
    (do
      skipChar '('
      let e ← expr
      ws
      skipChar ')'
      pure e)
    <|>
    integer

end

def parseExpr (s : String) : Option Expr :=
  match Parser.run expr s with
  | .ok e    => some e
  | .error _ => none

end Parser
