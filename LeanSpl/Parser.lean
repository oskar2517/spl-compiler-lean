import Std.Internal.Parsec.String

open Std.Internal.Parsec
open Std.Internal.Parsec.String

namespace Parser

inductive Expr where
  | num (n : Int)
  | add (l r : Expr)
  | sub (l r : Expr)
  | mul (l r : Expr)
  | div (l r : Expr)
  deriving Repr

abbrev Parser (α : Type) := Std.Internal.Parsec.String.Parser α

def integer : Parser Expr := do
  ws
  let neg ←
    (skipChar '-' *> pure true)
    <|> pure false

  let digitsStr ← many1Chars digit
  let n := digitsStr.toInt!
  let n := if neg then -n else n
  pure <| Expr.num n

mutual

  partial def expr : Parser Expr := do
    let left ← term
    expr' left

  partial def expr' (left : Expr) : Parser Expr := do
    ws
    (do
      skipChar '+'
      let right ← term
      expr' (Expr.add left right))
    <|>
    (do
      skipChar '-'
      let right ← term
      expr' (Expr.sub left right))
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
      term' (Expr.mul left right))
    <|>
    (do
      skipChar '/'
      let right ← factor
      term' (Expr.div left right))
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
