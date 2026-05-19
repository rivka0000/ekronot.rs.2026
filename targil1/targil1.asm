@256
D=A
@SP
M=D
// push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop argument 2
@ARG
D=M
@2
D=D+A
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// push constant 8
@8
D=A
@SP
A=M
M=D
@SP
M=M+1
// neg
@SP
A=M-1
M=-M
// pop local 4
@LCL
D=M
@4
D=D+A
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// push constant 7
@7
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop temp 0
@5
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// push constant 10
@10
D=A
@SP
A=M
M=D
@SP
M=M+1
// push local 4
@LCL
D=M
@4
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push temp 0
@5
D=M
@SP
A=M
M=D
@SP
M=M+1
// push from_try 3
@19
D=M
@SP
A=M
M=D
@SP
M=M+1
// pop argument 3
@ARG
D=M
@3
D=D+A
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
