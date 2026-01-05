import Std.Internal.Parsec.String
import LeanSpl.Absyn

open Std.Internal.Parsec
open Std.Internal.Parsec.String

namespace Parser
open Absyn

abbrev Parser (α : Type) := Std.Internal.Parsec.String.Parser α

def ws1 : Parser Unit :=
  (many1Chars (satisfy Char.isWhitespace)) *> pure ()

partial def comment : Parser Unit :=
  skipString "//" *> manyChars (satisfy (· != '\n')) *> (optional (skipChar '\n') *> pure ())

partial def whitespace : Parser Unit :=
  (many (ws1 <|> comment)) *> pure ()

def lexeme (p : Parser α) : Parser α :=
  whitespace *> p <* whitespace

def symbol (s : String) : Parser Unit :=
  lexeme (skipString s)

def sepBy1 (p : Parser α) (sep : Parser Unit) : Parser (List α) := do
  let x ← p
  let xs ← many (sep *> p)
  pure (x :: xs.toList)

def sepBy {α} (p : Parser α) (sep : Parser Unit) : Parser (List α) :=
  sepBy1 p sep <|> pure []

partial def chainl1 (p : Parser α) (op : Parser (α -> α -> α)) : Parser α := do
  let mut x <- p
  repeat do
    let r <- attempt (some <$> op) <|> pure none
    match r with
    | none => return x
    | some f =>
      let y <- p
      x := f x y
  unreachable!

def isKeyword (s : String) : Bool :=
  s == "if" || s == "else" || s == "while" ||
  s == "proc" || s == "type" || s == "var" ||
  s == "array" || s == "of" || s == "ref"

def ident : Parser String := do
  let first <- asciiLetter <|> pchar '_'
  let later <- manyChars (asciiLetter <|> pchar '_' <|> digit)
  let s :=  first.toString ++ later
  if isKeyword s then
    fail s!"keyword '{s}' cannot be used as identifier"
  else
    pure s

def charLiteral : Parser Int := do
  skipChar '\''
  let char <- take 1
  skipChar '\''
  pure char.front.toNat

def charNewLine : Parser Int := do
  let _ <- pstring "'\\n'"
  pure '\n'.toNat

def character : Parser Int := attempt charNewLine <|> charLiteral

def decInteger : Parser Int := do
  let digitsStr <- many1Chars digit
  let n := digitsStr.toInt!
  pure n

def hexInteger : Parser Int := do
  skipString "0x"
  let cs <- many1 hexDigit
  let ds := cs.map (fun d =>
    if d.isDigit then
      d.toNat - '0'.toNat
    else
      d.toLower.toNat - 'a'.toNat + 10
  )
  pure <| ds.foldl (fun acc d => acc * 16 + Int.ofNat d) 0

def integer : Parser Int := attempt hexInteger <|> decInteger

def intlit : Parser Int := integer <|> character

def namedTypeExpr : Parser TypeExpr := do
  let id <- lexeme ident
  pure <| TypeExpr.named id

mutual
  partial def arrayTypeExpr : Parser TypeExpr := do
    symbol "array"
    symbol "["
    let len <- lexeme intlit
    symbol "]"
    symbol "of"
    let te <- typeExpr
    pure <| TypeExpr.array (len.toNat) te

  partial def typeExpr : Parser TypeExpr := arrayTypeExpr <|> namedTypeExpr
end

def refParam : Parser ParamDef := do
  symbol "ref"
  let id <- lexeme ident
  symbol ":"
  let te <- typeExpr
  pure <| ParamDef.mk id te true

def nonRefParam : Parser ParamDef := do
  let id <- lexeme ident
  symbol ":"
  let te <- typeExpr
  pure <| ParamDef.mk id te false

def parameter : Parser ParamDef := refParam <|> nonRefParam

def paramList : Parser (List ParamDef) := sepBy parameter (symbol ",")

def eq : Parser BinOp := symbol "=" *> pure BinOp.eq

def ne : Parser BinOp := symbol "#" *> pure BinOp.ne

def lt : Parser BinOp := symbol "<" *> pure BinOp.lt

def gt : Parser BinOp := symbol ">" *> pure BinOp.gt

def le : Parser BinOp := symbol "<=" *> pure BinOp.le

def ge : Parser BinOp := symbol ">=" *> pure BinOp.ge

def add : Parser BinOp := symbol "+" *> pure BinOp.add

def sub : Parser BinOp := symbol "-" *> pure BinOp.sub

def mul : Parser BinOp := symbol "*" *> pure BinOp.mul

def div : Parser BinOp := symbol "/" *> pure BinOp.div

def intExpr : Parser Expr := do
  let i <- lexeme intlit
  pure <| Expr.int i

def namedVariable : Parser Variable := do
  let id <- lexeme ident
  pure <| Variable.named id

partial def expr2Op : Parser (Expr -> Expr -> Expr) :=
  (mul *> pure (fun l r => Expr.bin BinOp.mul l r))
  <|> (div *> pure (fun l r => Expr.bin BinOp.div l r))

partial def expr1Op : Parser (Expr -> Expr -> Expr) :=
  (add *> pure (fun l r => Expr.bin BinOp.add l r))
  <|> (sub *> pure (fun l r => Expr.bin BinOp.sub l r))

mutual
  partial def indexedVariable : Parser Variable := do
    let base <- namedVariable
    let arr <- many (do
      symbol "["
      let ex <- expr
      symbol "]"
      pure ex
    )
    pure <| arr.foldl (fun var e => Variable.index var e) base

  partial def variableExpr : Parser Expr := do
    let var <- indexedVariable
    pure <| Expr.var var

  partial def parenthesisExpr : Parser Expr := do
    symbol "("
    let ex <- expr
    symbol ")"
    pure ex

  partial def expr4 : Parser Expr := intExpr <|> variableExpr <|> parenthesisExpr

  partial def expr3 : Parser Expr :=
    (do
      symbol "-"
      let ex <- expr3
      pure <| Expr.un UnOp.neg ex
    ) <|> expr4

  partial def expr2 : Parser Expr := chainl1 expr3 expr2Op

  partial def expr1 : Parser Expr := chainl1 expr2 expr1Op

  partial def expr0 : Parser Expr := do
    let left <- expr1
    attempt (do
      let op <- le <|> lt <|> ge <|> gt <|> eq <|> ne
      let right <- expr1 -- No-assoc
      pure <| Expr.bin op left right
    ) <|> pure left

  partial def expr : Parser Expr := expr0
end

def argumentList : Parser (List Expr) := sepBy expr (symbol ",")

def emptyStatement : Parser Stmt := do
  symbol ";"
  pure Stmt.empty

def callStatement : Parser Stmt := do
  let id <- lexeme ident
  symbol "("
  let args <- argumentList
  symbol ")"
  symbol ";"
  pure <| Stmt.call id args

mutual
  partial def ifStatement : Parser Stmt := do
    symbol "if"
    symbol "("
    let c ← expr
    symbol ")"
    let t ← statement
    let e ← (some <$> (symbol "else" *> statement)) <|> pure none
    pure <| Stmt.if_ c t e

  partial def assignStatement : Parser Stmt := do
    let var <- indexedVariable
    symbol ":="
    let ex <- expr
    symbol ";"
    pure <| Stmt.assign var ex

  partial def whileStatement : Parser Stmt := do
    symbol "while"
    symbol "("
    let ex <- expr
    symbol ")"
    let st <- statement
    pure <| Stmt.while_ ex st

  partial def compoundStatement : Parser Stmt := do
    symbol "{"
    let st <- many statement
    symbol "}"
    pure <| Stmt.block st.toList

  partial def statement : Parser Stmt :=
    emptyStatement <|> ifStatement <|> attempt assignStatement
    <|> whileStatement <|> compoundStatement <|> callStatement
end

def variableDef : Parser VarDef := do
  symbol "var"
  let name <- ident
  symbol ":"
  let te <- typeExpr
  symbol ";"
  pure <| VarDef.mk name te

def procDef : Parser ProcDef := do
  symbol "proc"
  let name <- ident
  symbol "("
  let params <- paramList
  symbol ")"
  symbol "{"
  let vars <- many variableDef
  let statements <- many statement
  symbol "}"
  pure <| ProcDef.mk name params vars.toList statements.toList

def typeDef : Parser TypeDef := do
  symbol "type"
  let id <- ident
  symbol "="
  let typeExpr <- typeExpr
  symbol ";"
  pure <| TypeDef.mk id typeExpr

def globalDef : Parser GlobalDef := do
  (GlobalDef.type <$> typeDef)
  <|>
  (GlobalDef.procedure <$> procDef)

partial def globalDefList : Parser (List GlobalDef) := do
  whitespace
  let defs <- many globalDef
  eof
  pure defs.toList

def parse (s: String) : Except String (List GlobalDef) :=
  Parser.run globalDefList s

end Parser
