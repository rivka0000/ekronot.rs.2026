#Rivka Azrad - 215041013
#Sara Alvesson - 328958186
#group number: 44

# global variables
global outFile
global logicCounter

# arithmetic functions

function handleAdd()
    global outFile
    println(outFile, "command: add")
end

function handleSub()
    global outFile
    println(outFile, "command: sub")
end

function handleNeg()
    global outFile
    println(outFile, "command: neg")
end

# logic functions

function handleEq()
    global outFile, logicCounter
    println(outFile, "command: eq")
    println(outFile, "counter: ", logicCounter)
    logicCounter += 1
end

function handleGt()
    global outFile, logicCounter
    println(outFile, "command: gt")
    println(outFile, "counter: ", logicCounter)
    logicCounter += 1
end

function handleLt()
    global outFile, logicCounter
    println(outFile, "command: lt")
    println(outFile, "counter: ", logicCounter)
    logicCounter += 1
end

# memory commands

function handlePush(segment, index)
    global outFile
    println(outFile, "command: push segment $segment index $index")
end

function handlePop(segment, index)
    global outFile
    println(outFile, "command: pop segment $segment index $index")
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

# go over all files
for file in files

    # check if file is vm
    if endswith(file, ".vm")

        # reset logic counter
        global logicCounter = 1

        filePath = joinpath(folderPath, file)

        # open input file
        inputFile = open(filePath)

        # read file line by line
        for line in eachline(inputFile)

            # split line into words
            words = split(line)

            if length(words) == 0 || startswith(words[1], "//")
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

            elseif command == "push"
                segment = words[2]
                index = words[3]
                handlePush(segment, index)

            elseif command == "pop"
                segment = words[2]
                index = words[3]
                handlePop(segment, index)

            end

        end

        close(inputFile)

        println("End of input file: ", file)

    end

end

# close output file
close(outFile)

println("Output file is ready: ", outputFileName)