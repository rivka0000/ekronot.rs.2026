#Rivka Azrad - 215041013
#Sara Alvesson - 328958186
#group number: 44

# global variables
global outFile
global logicCounter

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

# read files from folder
files = readdir(folderPath)

# reset logic counter
global logicCounter = 1

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

            end

        end

        close(inputFile)

        println("End of input file: ", file)

    end

end

# close output file
close(outFile)

println("Output file is ready: ", outputFileName)