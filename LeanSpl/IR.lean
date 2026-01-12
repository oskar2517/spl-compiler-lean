namespace IR

inductive LLVMType where
  | i64
  | i1
  | arr (size : Nat) (base : LLVMType)
  | ref (base : LLVMType)
  | void
  deriving Repr, Inhabited

def LLVMType.toString : LLVMType -> String
  | .i64 => "i64"
  | .i1 => "i1"
  | .arr size base => s!"[{size} x {LLVMType.toString base}]"
  | .ref base => s!"{LLVMType.toString base}*"
  | .void => "void"

instance : ToString LLVMType where
  toString := LLVMType.toString

structure Label where
  name: String
  raw: Bool := false
  deriving Repr, Inhabited

instance : ToString Label where
  toString l := if l.raw then l.name else s!"%L{l.name}"

def Label.definition (l : Label) : String :=
  if l.raw then s!"{l.name}:" else s!"L{l.name}:"

structure Register where
  name: String
  deriving Repr, Inhabited

instance : ToString Register where
  toString r := s!"%{r.name}"

def Register.addr (r : Register) : Register :=
  Register.mk <| r.name ++ ".addr"

structure Global where
  name: String
  raw: Bool
  deriving Repr, Inhabited

instance : ToString Global where
  toString g := if g.raw then s!"@{g.name}" else s!"@_{g.name}"

inductive RelOp where
  | eq
  | ne
  | slt
  | sle
  | sgt
  | sge
  deriving Repr

instance : ToString RelOp where
  toString
  | .eq => "eq"
  | .ne => "ne"
  | .slt => "slt"
  | .sle => "sle"
  | .sgt => "sgt"
  | .sge => "sge"

structure Operand where
  type: LLVMType
  register: Register
  deriving Repr, Inhabited

instance : ToString Operand where
  toString o := s!"{o.type} {o.register}"

inductive Instruction where
  | icmp (target : Register) (op : RelOp) (left right : Register)
  | getelementptr (target : Register) (type : LLVMType) (base offset : Register)
  | getelementptr_nop (target : Register) (address : Register)
  | store (type : LLVMType) (value : Register) (address : Register)
  | load (target: Register) (type : LLVMType) (address : Register)
  | br_con (condition : Register) (label_then : Label) (label_else : Label)
  | br (label: Label)
  | call (name : Global) (arguments : List Operand)
  | add (target : Register) (left right : Register)
  | add_ld (target : Register) (right : Int)
  | sub (target : Register) (left right : Register)
  | sub_imm (target : Register) (right : Register)
  | mul (target : Register) (left right : Register)
  | sdiv (target : Register) (left right : Register)
  | alloca (target : Register) (type : LLVMType)
  | ret
  | ret_null
  deriving Repr, Inhabited

instance : ToString Instruction where
  toString
  | .icmp target op left right => s!"{target} = icmp {op} i64 {left}, {right}"
  | .getelementptr target type base offset => s!"{target} = getelementptr {type}, {type}* {base}, i64 0, i64 {offset}"
  | .getelementptr_nop target address => s!"{target} = getelementptr i64, i64* {address}, i64 0"
  | .store type value address => s!"store {type} {value}, {type}* {address}, align 8"
  | .load target type address => s!"{target} = load {type}, i64* {address}"
  | .br_con condition label_then label_else => s!"br i1 {condition}, label {label_then}, label {label_else}"
  | .br label => s!"br label {label}"
  | .call name arguments => s!"call void {name}({String.intercalate ", " (arguments.map ToString.toString)})"
  | .add target left right => s!"{target} = add i64 {left}, {right}"
  | .add_ld target right => s!"{target} = add i64 0, {right}"
  | .sub target left right => s!"{target} = sub i64 {left}, {right}"
  | .sub_imm target right => s!"{target} = sub i64 0, {right}"
  | .mul target left right => s!"{target} = mul i64 {left}, {right}"
  | .sdiv target left right => s!"{target} = sdiv i64 {left}, {right}"
  | .alloca target type => s!"{target} = alloca {type}, align 8"
  | .ret => "ret void"
  | .ret_null => "ret i64 0"

inductive BodyElement where
  | label (l : Label)
  | instruction (i : Instruction)
  deriving Repr

instance : ToString BodyElement where
  toString
  | .label l => l.definition
  | .instruction i => s!"    {i}"

structure Function where
  name: Global
  type: LLVMType
  parameters: List Operand
  body: List BodyElement
  deriving Repr, Inhabited

instance : ToString Function where
  toString f :=
    let parameters := String.intercalate ", " (f.parameters.map ToString.toString)
    let body := String.intercalate "\n" (f.body.map ToString.toString)
    s!"define {f.type} {f.name}({parameters}) " ++ "{\n" ++ body ++ "\n}\n"

structure Declaration where
  name: Global
  parameters: List LLVMType
  deriving Repr

instance : ToString Declaration where
  toString f :=
    let parameters := String.intercalate ", " (f.parameters.map ToString.toString)
    s!"declare void {f.name}({parameters})"

inductive ProgramElement where
  | decl (d : Declaration)
  | func (f : Function)
  deriving Repr

structure Program where
  declarations: List Declaration
  functions: List Function
  deriving Repr

instance : ToString Program where
  toString p := String.intercalate "\n" (p.declarations.map ToString.toString)
  ++ "\n\n" ++ String.intercalate "\n" (p.functions.map ToString.toString)

end IR
