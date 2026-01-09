import LeanSpl.Parser
import LeanSpl.SemanticAnalysis
import LeanSpl.TableBuilder
import LeanSpl.CodeGenerator

def padString (w : Nat) (s : String) : String :=
  if s.length >= w then
    s
  else
    s ++ String.mk (List.replicate (w - s.length) ' ')

def compile (prog: String) (fileName: String): IO Unit :=
    match Parser.parse prog with
            | Except.ok ast => match TableBuilder.buildSymbolTable ast with
                | Except.ok table => match SemanticAnalysis.checkProgram ast table with
                    | Except.ok _ => IO.println s!"{padString 20 fileName}: \x1b[32mno errors found\x1b[0m"
                    | Except.error e => IO.println s!"\x1b[1;31merror:\x1b[0m {fileName}: {e}"
                | Except.error e => IO.println s!"\x1b[1;31merror:\x1b[0m {fileName}: {e}"
            | Except.error e => IO.println s!"\x1b[1;31merror:\x1b[0m {fileName}: {e}"

def debugCompile (prog: String): IO Unit :=
    match Parser.parse prog with
            | Except.ok ast => match TableBuilder.buildSymbolTable ast with
                | Except.ok table => match SemanticAnalysis.checkProgram ast table with
                    | Except.ok _ => do
                        let (ir, _st) := (CodeGenerator.compileProgram ast table).run {}
                        IO.println s!"{ir}"
                    | Except.error e => IO.println s!"merror: {e}"
                | Except.error e => IO.println s!"merror: {e}"
            | Except.error e => IO.println s!"merror: {e}"

def main : IO Unit := do
    let testPath <- pure <| ⟨ "./runtime_tests" ⟩
    let dir <- System.FilePath.readDir testPath

    for file in dir do
        let handle <- IO.FS.Handle.mk s!"./runtime_tests/{file.fileName}" IO.FS.Mode.read
        let contents <- IO.FS.Handle.readToEnd handle

        compile contents file.fileName


#eval debugCompile "
proc main() {
    while (1 = 1) {
        printi(1);
        printi(2);
        }

}
"
