import LeanSpl.Parser

def main : IO Unit := IO.println "Hello World"

#eval Parser.parse "
// This is a comment
// This is another
proc main() {
  var x: int;

  x := 1 + 2 * 3;

  if (x > 5) {
    printi(1);
  }
}
"
