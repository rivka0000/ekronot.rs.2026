#Rivka Azrad - 215041013
#Sara Alvesson - 328958186
#group number: 44

# global variables
global outFile
global logicCounter
global currentFunctionName

# arithmetic functions

function handleAdd()
    global outFile
    println(outFile, "@SP") #A=SP=0
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "D=M")   #D=RAM[A]  
    println(outFile, "A=A-1")   #A=A-1
    println(outFile, "M=D+M")   #RAM[A]=D+RAM[A]
    println(outFile, "@SP")  #A=SP
    println(outFile, "M=M-1")  #SP=SP-1
end

function handleSub()
    global outFile
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "D=M")   #D=RAM[A]
    println(outFile, "A=A-1")   #A=A-1
    println(outFile, "M=M-D")   #RAM[A]=RAM[A]-D
    println(outFile, "@SP")  #A=SP
    println(outFile, "M=M-1")  #SP=SP-1
end

function handleNeg()
    global outFile
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "M=-M")   #RAM[A]=-RAM[A]
end


# logic functions

function handleEq()
    global outFile, logicCounter

    trueLabel = "IFTRUE" * string(logicCounter)
    endLabel = "END" * string(logicCounter)

    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "D=M") #D=RAM[A]
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "D=M-D") #D=RAM[A]-D
    println(outFile, "@$trueLabel") #A=trueLabel
    println(outFile, "D;JEQ") #jumpif_D==0
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=0") #RAM[A]=0
    println(outFile, "@$endLabel") #A=endLabel
    println(outFile, "0;JMP") #jump
    println(outFile, "($trueLabel)") #labeltrue
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=-1") #RAM[A]=-1
    println(outFile, "($endLabel)") #labelend
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1

    logicCounter += 1
end

function handleGt()
    global outFile, logicCounter
    trueLabel = "IFTRUE" * string(logicCounter)
    endLabel = "END" * string(logicCounter)

    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "D=M") #D=RAM[A]
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "D=M-D") #D=RAM[A]-D
    println(outFile, "@$trueLabel") #A=trueLabel
    println(outFile, "D;JGT") #jumpif_D>0
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=0") #RAM[A]=0
    println(outFile, "@$endLabel") #A=endLabel
    println(outFile, "0;JMP") #jump
    println(outFile, "($trueLabel)") #labeltrue
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=-1") #RAM[A]=-1
    println(outFile, "($endLabel)") #labelend
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1
    logicCounter += 1
end

function handleLt()
    global outFile, logicCounter
    trueLabel = "IFTRUE" * string(logicCounter)
    endLabel = "END" * string(logicCounter)

    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "D=M") #D=RAM[A]
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "D=M-D") #D=RAM[A]-D
    println(outFile, "@$trueLabel") #A=trueLabel
    println(outFile, "D;JLT") #jumpif_D<0
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=0") #RAM[A]=0
    println(outFile, "@$endLabel") #A=endLabel
    println(outFile, "0;JMP") #jump
    println(outFile, "($trueLabel)") #labeltrue
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=-1") #RAM[A]=-1
    println(outFile, "($endLabel)") #labelend
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1
    logicCounter += 1
end

# memory commands

function handlePush(segment, index, fileNameWithoutExtension)
    global outFile

    if segment == "constant"

        println(outFile, "@$index") #A=index
        println(outFile, "D=A") #D=index

    elseif segment == "local"

        println(outFile, "@LCL") #A=LCL
        println(outFile, "D=M") #D=RAM[LCL]
        println(outFile, "@$index") #A=index
        println(outFile, "A=D+A") #A=D+A
        println(outFile, "D=M") #D=RAM[A]

    elseif segment == "argument"

        println(outFile, "@ARG") #A=ARG
        println(outFile, "D=M") #D=RAM[ARG]
        println(outFile, "@$index") #A=index
        println(outFile, "A=D+A") #A=D+A
        println(outFile, "D=M") #D=RAM[A]

    elseif segment == "this"

        println(outFile, "@THIS") #A=THIS
        println(outFile, "D=M") #D=RAM[THIS]
        println(outFile, "@$index") #A=index
        println(outFile, "A=D+A") #A=D+A
        println(outFile, "D=M") #D=RAM[A]

    elseif segment == "that"

        println(outFile, "@THAT") #A=THAT
        println(outFile, "D=M") #D=RAM[THAT]
        println(outFile, "@$index") #A=index
        println(outFile, "A=D+A") #A=D+A
        println(outFile, "D=M") #D=RAM[A]

    elseif segment == "temp"

        println(outFile, "@$(5 + index)") #A=5+index
        println(outFile, "D=M") #D=RAM[A]

    elseif segment == "static"

        println(outFile, "@$(fileNameWithoutExtension).$index") #A=static_variable
        println(outFile, "D=M") #D=RAM[A]

    elseif segment == "pointer"

        if index == 0
            println(outFile, "@THIS") #A=THIS
        else
            println(outFile, "@THAT") #A=THAT
        end
        println(outFile, "D=M") #D=RAM[A]

    end

    println(outFile, "@SP") #A=SP
    println(outFile, "A=M") #A=RAM[SP]
    println(outFile, "M=D") #RAM[A]=D
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M+1") #SP=SP+1
end

function handlePop(segment, index, fileNameWithoutExtension)
    global outFile

    if segment == "local"

        println(outFile, "@LCL") #A=LCL
        println(outFile, "D=M") #D=RAM[LCL]
        println(outFile, "@$index") #A=index
        println(outFile, "D=D+A") #D=D+A
        println(outFile, "@R13") #A=R13
        println(outFile, "M=D") #RAM[R13]=D

    elseif segment == "argument"

        println(outFile, "@ARG") #A=ARG
        println(outFile, "D=M") #D=RAM[ARG]
        println(outFile, "@$index") #A=index
        println(outFile, "D=D+A") #D=D+A
        println(outFile, "@R13") #A=R13
        println(outFile, "M=D") #RAM[R13]=D

    elseif segment == "this"

        println(outFile, "@THIS") #A=THIS
        println(outFile, "D=M") #D=RAM[THIS]
        println(outFile, "@$index") #A=index
        println(outFile, "D=D+A") #D=D+A
        println(outFile, "@R13") #A=R13
        println(outFile, "M=D") #RAM[R13]=D

    elseif segment == "that"

        println(outFile, "@THAT") #A=THAT
        println(outFile, "D=M") #D=RAM[THAT]
        println(outFile, "@$index") #A=index
        println(outFile, "D=D+A") #D=D+A
        println(outFile, "@R13") #A=R13
        println(outFile, "M=D") #RAM[R13]=D

    elseif segment == "temp"

        println(outFile, "@$(5 + index)") #A=5+index
        println(outFile, "D=A") #D=A
        println(outFile, "@R13") #A=R13
        println(outFile, "M=D") #RAM[R13]=D

    elseif segment == "static"

        println(outFile, "@$(fileNameWithoutExtension).$index") #A=static_variable
        println(outFile, "D=A") #D=A
        println(outFile, "@R13") #A=R13
        println(outFile, "M=D") #RAM[R13]=D

    elseif segment == "pointer"

        if index == 0
            println(outFile, "@THIS") #A=THIS
        else
            println(outFile, "@THAT") #A=THAT
        end
        println(outFile, "D=A") #D=A
        println(outFile, "@R13") #A=R13
        println(outFile, "M=D") #RAM[R13]=D

    end

    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1
    println(outFile, "A=M") #A=RAM[SP]
    println(outFile, "D=M") #D=RAM[A]

    println(outFile, "@R13") #A=R13
    println(outFile, "A=M") #A=RAM[R13]
    println(outFile, "M=D") #RAM[A]=D
end


function handleAnd()
    global outFile
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "D=M") #D=RAM[A]
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=D&M") #RAM[A]=D&M
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1
end

function handleOr()
    global outFile
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "D=M") #D=RAM[A]
    println(outFile, "A=A-1") #A=A-1
    println(outFile, "M=D|M") #RAM[A]=D|M
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1
end

function handleNot()
    global outFile
    println(outFile, "@SP") #A=SP
    println(outFile, "A=M-1") #A=RAM[A]-1
    println(outFile, "M=!M") #RAM[A]=!RAM[A]
end


#A function to get a label name that is unique within the current function scope. If we're in the global scope, 
#it uses the file name to ensure uniqueness across files. If we're inside a function, it uses the function name 
#to ensure uniqueness within that function.
function getScopedLabel(labelName, fileNameWithoutExtension)
    global currentFunctionName

    if currentFunctionName == ""
        return fileNameWithoutExtension * "\$" * labelName
    else
        return currentFunctionName * "\$" * labelName
    end
end

# program flow commands

function handleLabel(labelName, fileNameWithoutExtension)
    global outFile, currentFunctionName

    println(outFile, "(" * getScopedLabel(labelName, fileNameWithoutExtension) * ")")#A=(functionName$labelName) or (fileName$labelName)
end

function handleGoto(labelName, fileNameWithoutExtension)
    global outFile, currentFunctionName

    println(outFile, "@" * getScopedLabel(labelName, fileNameWithoutExtension))#A=label
    println(outFile, "0;JMP")#jump
end

function handleIfGoto(labelName, fileNameWithoutExtension)
    global outFile, currentFunctionName

    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1 (pop)
    println(outFile, "A=M") #A=top of stack (new SP)
    println(outFile, "D=M") #D=RAM[A] (popped value)
    println(outFile, "@" * getScopedLabel(labelName, fileNameWithoutExtension))#A=label
    println(outFile, "D;JNE")#jump if D!=0
end


# function calling commands

function handleFunction(functionName, numLocals, fileNameWithoutExtension)
    global outFile, currentFunctionName

    # update current function name
    currentFunctionName = functionName

    # declare function label
    println(outFile, "(" * functionName * ")")

    # initialize local variables to 0
    for i in 1:numLocals
        handlePush("constant", 0, fileNameWithoutExtension)
    end
end

function pushDToStack()
    global outFile

    println(outFile, "@SP") #A=SP
    println(outFile, "A=M") #A=top of stack (current SP)
    println(outFile, "M=D") #RAM[A]=D (push D onto stack)
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M+1") #SP=SP+1 (advance stack pointer)
end

function handleCall(functionName, numArgs)
    global outFile, logicCounter

    returnLabel = "RETURN_" * string(logicCounter) #create unique return label name
    logicCounter += 1 #advance counter for next unique label

    # push return address
    println(outFile, "@" * returnLabel) #A=address of return label
    println(outFile, "D=A") #D=return address
    pushDToStack()

    # push LCL
    println(outFile, "@LCL") #A=LCL
    println(outFile, "D=M") #D=RAM[LCL]
    pushDToStack()

    # push ARG
    println(outFile, "@ARG") #A=ARG
    println(outFile, "D=M") #D=RAM[ARG]
    pushDToStack()

    # push THIS
    println(outFile, "@THIS") #A=THIS
    println(outFile, "D=M") #D=RAM[THIS]
    pushDToStack()

    # push THAT
    println(outFile, "@THAT") #A=THAT
    println(outFile, "D=M") #D=RAM[THAT]
    pushDToStack()

    # ARG = SP - numArgs - 5
    println(outFile, "@SP") #A=SP
    println(outFile, "D=M") #D=SP
    println(outFile, "@" * string(numArgs + 5)) #A=numArgs+5
    println(outFile, "D=D-A") #D=SP-numArgs-5
    println(outFile, "@ARG") #A=ARG
    println(outFile, "M=D") #ARG=SP-numArgs-5

    # LCL = SP
    println(outFile, "@SP") #A=SP
    println(outFile, "D=M") #D=SP
    println(outFile, "@LCL") #A=LCL
    println(outFile, "M=D") #LCL=SP

    # goto function
    println(outFile, "@" * functionName) #A=address of called function
    println(outFile, "0;JMP") #jump to function

    # return label
    println(outFile, "(" * returnLabel * ")") #creates return label location
end

function handleReturn()
    global outFile

    # FRAME = LCL
    println(outFile, "@LCL") #A=LCL
    println(outFile, "D=M") #D=LCL
    println(outFile, "@R13") #A=R13
    println(outFile, "M=D") #R13=FRAME=LCL

    # RET = *(FRAME - 5)
    println(outFile, "@5") #A=5
    println(outFile, "A=D-A") #A=FRAME-5
    println(outFile, "D=M") #D=RAM[FRAME-5] = return address
    println(outFile, "@R14") #A=R14
    println(outFile, "M=D") #R14=RET

    # *ARG = pop()
    println(outFile, "@SP") #A=SP
    println(outFile, "M=M-1") #SP=SP-1
    println(outFile, "A=M") #A=top of stack
    println(outFile, "D=M") #D=pop() value
    println(outFile, "@ARG") #A=ARG
    println(outFile, "A=M") #A=RAM[ARG]
    println(outFile, "M=D") #*ARG=return value

    # SP = ARG + 1
    println(outFile, "@ARG") #A=ARG
    println(outFile, "D=M+1") #D=ARG+1
    println(outFile, "@SP") #A=SP
    println(outFile, "M=D") #SP=ARG+1

    # THAT = *(FRAME - 1)
    println(outFile, "@R13") #A=R13
    println(outFile, "AM=M-1") #FRAME=FRAME-1, A=FRAME
    println(outFile, "D=M") #D=*(FRAME-1)
    println(outFile, "@THAT") #A=THAT
    println(outFile, "M=D") #THAT=*(FRAME-1)

    # THIS = *(FRAME - 2)
    println(outFile, "@R13") #A=R13
    println(outFile, "AM=M-1") #FRAME=FRAME-1, A=FRAME
    println(outFile, "D=M") #D=*(FRAME-2)
    println(outFile, "@THIS") #A=THIS
    println(outFile, "M=D") #THIS=*(FRAME-2)

    # ARG = *(FRAME - 3)
    println(outFile, "@R13") #A=R13
    println(outFile, "AM=M-1") #FRAME=FRAME-1, A=FRAME
    println(outFile, "D=M") #D=*(FRAME-3)
    println(outFile, "@ARG") #A=ARG
    println(outFile, "M=D") #ARG=*(FRAME-3)

    # LCL = *(FRAME - 4)
    println(outFile, "@R13") #A=R13
    println(outFile, "AM=M-1") #FRAME=FRAME-1, A=FRAME
    println(outFile, "D=M") #D=*(FRAME-4)
    println(outFile, "@LCL") #A=LCL
    println(outFile, "M=D") #LCL=*(FRAME-4)

    # goto RET
    println(outFile, "@R14") #A=R14
    println(outFile, "A=M") #A=RET
    println(outFile, "0;JMP") #jump to return address
end


# bootstrap code

function writeBootstrap()
    global outFile

    # SP = 256
    println(outFile, "@256") #A=256
    println(outFile, "D=A") #D=256
    println(outFile, "@SP") #A=SP
    println(outFile, "M=D") #SP=256

    # call Sys.init 0
    handleCall("Sys.init", 0) #calls Sys.init with 0 arguments
end

# start of main program

println("Enter folder path:")
folderPath = readline()

# get folder name
folderName = splitpath(folderPath)[end]

# create output file name
outputFileName = folderName * ".asm"

# create full output path
outputPath = joinpath(folderPath, outputFileName)

# open output file
global outFile = open(outputPath, "w")

# reset logic counter
global logicCounter = 1

# initialize current function name
global currentFunctionName = ""

# Initialize SP to 256 and call Sys.init to start program execution.
#writeBootstrap()  # - According to the assignment instructions, this line should be used only for specific tests.
# Therefore, it is commented out by default. If required, uncomment this line to enable bootstrap initialization.


# read files from folder
files = readdir(folderPath)

# go over all files
for file in files

    # check if file is vm
    if endswith(file, ".vm")

        filePath = joinpath(folderPath, file)

        fileNameWithoutExtension = splitext(file)[1]

        # open input file
        inputFile = open(filePath)

        # read file line by line
        for line in eachline(inputFile)
            
            lineWithoutComments = first(split(line, "//"))
            cleanLine = strip(lineWithoutComments)
            if isempty(cleanLine)
                continue
            end

            # print the original VM command as a comment
            println(outFile, "// ", cleanLine)  # ← זו השורה החדשה

            words = split(cleanLine)

            if length(words) == 0
                continue
            end

            command = words[1]

            # identify command

            if command == "add"
                handleAdd()

            elseif command == "sub"
                handleSub()

            elseif command == "neg"
                handleNeg()

            elseif command == "eq"
                handleEq()

            elseif command == "gt"
                handleGt()

            elseif command == "lt"
                handleLt()

            elseif command == "and"
                handleAnd()

            elseif command == "or"
                handleOr()

            elseif command == "not"
                handleNot()

            elseif command == "push"
                segment = words[2]
                index = parse(Int, words[3])
                handlePush(segment, index, fileNameWithoutExtension)

            elseif command == "pop"
                segment = words[2]
                index = parse(Int, words[3])
                handlePop(segment, index, fileNameWithoutExtension)
            
            elseif command == "label"
                labelName = words[2]
                handleLabel(labelName, fileNameWithoutExtension)


            elseif command == "goto"
                labelName = words[2]
                handleGoto(labelName, fileNameWithoutExtension)
            
            elseif command == "if-goto"
                labelName = words[2]
                handleIfGoto(labelName, fileNameWithoutExtension)
            
            elseif command == "function"
                functionName = words[2]
                numLocals = parse(Int, words[3])
                handleFunction(functionName, numLocals, fileNameWithoutExtension)
            
            elseif command == "call"
                functionName = words[2]
                numArgs = parse(Int, words[3])
                handleCall(functionName, numArgs)
            
            elseif command == "return"
                handleReturn()

            end
            

        end

        close(inputFile)

        println("End of input file: ", file)

    end

end

# close output file
close(outFile)

println("Output file is ready: ", outputFileName)