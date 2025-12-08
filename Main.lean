import LeanSpl.Parser

def main : IO Unit := IO.println "Hello World"

#eval Parser.parseExpr "1 + 2 * 3"
