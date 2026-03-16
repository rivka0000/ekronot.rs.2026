#Rivka Azrad - 215041013
#Sara Alvesson - 328958186
#group number: 44

# global variables
global outFile
global logicCounter

# arithmetic functions

function handleAdd()
    global outFile
    println(outFile, "@SP")
    println(outFile, "A=M-1") 
    println(outFile, "D=M")     
    println(outFile, "A=A-1")   
    println(outFile, "M=D+M")   
    println(outFile, "@SP")  
    println(outFile, "M=M-1")  
end

function handleSub()
    global outFile
    println(outFile, "@SP")
    println(outFile, "A=M-1") 
    println(outFile, "D=M")     
    println(outFile, "A=A-1")   
    println(outFile, "M=M-D")   
    println(outFile, "@SP")  
    println(outFile, "M=M-1")  
end

function handleNeg()
    global outFile
    println(outFile, "@SP")
    println(outFile, "A=M-1")       
    println(outFile, "M=-M")   
end

# logic functions

function handleEq()
    global outFile, logicCounter

    trueLabel = "IFTRUE" * string(logicCounter)
    endLabel = "END" * string(logicCounter)

    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "D=M")
    println(outFile, "A=A-1")
    println(outFile, "D=M-D")
    println(outFile, "@$trueLabel")
    println(outFile, "D;JEQ")
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "A=A-1")
    println(outFile, "M=0")
    println(outFile, "@$endLabel")
    println(outFile, "0;JMP")
    println(outFile, "($trueLabel)")
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "A=A-1")
    println(outFile, "M=-1")
    println(outFile, "($endLabel)")
    println(outFile, "@SP")
    println(outFile, "M=M-1")

    logicCounter += 1
end

function handleGt()
    global outFile, logicCounter
    trueLabel = "IFTRUE" * string(logicCounter)
    endLabel = "END" * string(logicCounter)
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "D=M")
    println(outFile, "A=A-1")
    println(outFile, "D=M-D")
    println(outFile, "@$trueLabel")
    println(outFile, "D;JGT")
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "A=A-1")
    println(outFile, "M=0")
    println(outFile, "@$endLabel")
    println(outFile, "0;JMP")
    println(outFile, "($trueLabel)")
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "A=A-1")
    println(outFile, "M=-1")
    println(outFile, "($endLabel)")
    println(outFile, "@SP")
    println(outFile, "M=M-1")
    logicCounter += 1
end

function handleLt()
    global outFile, logicCounter
    trueLabel = "IFTRUE" * string(logicCounter)
    endLabel = "END" * string(logicCounter)
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "D=M")
    println(outFile, "A=A-1")
    println(outFile, "D=M-D")
    println(outFile, "@$trueLabel")
    println(outFile, "D;JLT")
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "A=A-1")
    println(outFile, "M=0")
    println(outFile, "@$endLabel")
    println(outFile, "0;JMP")
    println(outFile, "($trueLabel)")
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "A=A-1")
    println(outFile, "M=-1")
    println(outFile, "($endLabel)")
    println(outFile, "@SP")
    println(outFile, "M=M-1")
    logicCounter += 1
end
# memory commands

function handlePush(segment, index, fileNameWithoutExtension)
    global outFile

    if segment == "constant"

        println(outFile, "@$index")
        println(outFile, "D=A")

    elseif segment == "local"

        println(outFile, "@LCL")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "A=D+A")
        println(outFile, "D=M")

    elseif segment == "argument"

        println(outFile, "@ARG")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "A=D+A")
        println(outFile, "D=M")

    elseif segment == "this"

        println(outFile, "@THIS")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "A=D+A")
        println(outFile, "D=M")

    elseif segment == "that"

        println(outFile, "@THAT")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "A=D+A")
        println(outFile, "D=M")

    elseif segment == "temp"

        println(outFile, "@$(5 + index)")
        println(outFile, "D=M")

    elseif segment == "static"

        println(outFile, "@$(fileNameWithoutExtension).$index")
        println(outFile, "D=M")

    elseif segment == "pointer"

        if index == 0
            println(outFile, "@THIS")
        else
            println(outFile, "@THAT")
        end
        println(outFile, "D=M")
     
        

    end

    println(outFile, "@SP")
    println(outFile, "A=M")
    println(outFile, "M=D")
    println(outFile, "@SP")
    println(outFile, "M=M+1")
end

function handlePop(segment, index, fileNameWithoutExtension)
    global outFile

    if segment == "local"

        println(outFile, "@LCL")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "D=D+A")
        println(outFile, "@R13")
        println(outFile, "M=D")

    elseif segment == "argument"

        println(outFile, "@ARG")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "D=D+A")
        println(outFile, "@R13")
        println(outFile, "M=D")

    elseif segment == "this"

        println(outFile, "@THIS")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "D=D+A")
        println(outFile, "@R13")
        println(outFile, "M=D")

    elseif segment == "that"

        println(outFile, "@THAT")
        println(outFile, "D=M")
        println(outFile, "@$index")
        println(outFile, "D=D+A")
        println(outFile, "@R13")
        println(outFile, "M=D")

    elseif segment == "temp"

        println(outFile, "@$(5 + index)")
        println(outFile, "D=A")
        println(outFile, "@R13")
        println(outFile, "M=D")

    elseif segment == "static"

        println(outFile, "@$(fileNameWithoutExtension).$index")
        println(outFile, "D=A")
        println(outFile, "@R13")
        println(outFile, "M=D")

    elseif segment == "pointer"

        if index == 0
            println(outFile, "@THIS")
        else
            println(outFile, "@THAT")
        end
        println(outFile, "D=A")
        println(outFile, "@R13")
        println(outFile, "M=D")

    end

    println(outFile, "@SP")
    println(outFile, "M=M-1")
    println(outFile, "A=M")
    println(outFile, "D=M")

    println(outFile, "@R13")
    println(outFile, "A=M")
    println(outFile, "M=D")
end

function handleAnd()
    global outFile
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "D=M")
    println(outFile, "A=A-1")
    println(outFile, "M=D&M")
    println(outFile, "@SP")
    println(outFile, "M=M-1")
end

function handleOr()
    global outFile
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "D=M")
    println(outFile, "A=A-1")
    println(outFile, "M=D|M")
    println(outFile, "@SP")
    println(outFile, "M=M-1")
end

function handleNot()
    global outFile
    println(outFile, "@SP")
    println(outFile, "A=M-1")
    println(outFile, "M=!M")
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
            
            lineWithoutComments = split(line, "//")[1]
    
            cleanLine = strip(lineWithoutComments)

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