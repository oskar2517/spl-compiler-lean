import LeanSpl.Parser

def main : IO Unit := IO.println "Hello World"

#eval Parser.parse "i + (i + (i + (i + (i + (i + (i + (i + (i +
       (i + (i + (i + (i + (i + i)))))))))))))"
