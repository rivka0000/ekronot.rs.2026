# ====================================================================
# File: JackAnalyzer.jl
# Role: Main program for the Jack compiler.
#       Receives a .jack file path or a directory path, and creates
#       a corresponding .vm file for each Jack source file.
# ====================================================================

include("JackTokenizer.jl")
include("SymbolTable.jl")
include("VMWriter.jl")
include("CompilationEngine.jl")

# Compiles a single Jack source file into a VM file
function compile_file(jack_file_path::String)
    output_file_path = replace(jack_file_path, ".jack" => ".vm")

    println("Compiling VM for file: ", jack_file_path, " -> Generating: ", output_file_path)

    tokenizer = create_tokenizer(jack_file_path)
    engine = create_engine(tokenizer, output_file_path)

    # Start compilation from the class level
    compile_class!(engine)

    # Close the output VM file
    close_engine!(engine)
end

# Main entry point of the compiler
function main()
    source_path = ""

    # Check if a path was supplied as a command-line argument
    if length(ARGS) >= 1
        source_path = ARGS[1]
    else
        # Otherwise, ask the user to enter a path manually
        print("Please enter a .jack file path or a directory path to process: ")
        source_path = strip(readline())
    end

    # Collection of Jack files to compile
    jack_files = String[]

    # If the path is a single Jack file, add it to the list
    if isfile(source_path) && endswith(source_path, ".jack")
        push!(jack_files, source_path)

    # If the path is a directory, collect all Jack files inside it
    elseif isdir(source_path)
        all_files = readdir(source_path, join=true)
        jack_files = filter(file -> endswith(file, ".jack"), all_files)

    # Invalid input path
    else
        println("Error: Please enter either a valid .jack file path or a valid directory path.")
        return
    end

    # Make sure at least one Jack file was found
    if isempty(jack_files)
        println("No .jack files were found.")
        return
    end

    # Compile every discovered Jack file
    for file in jack_files
        compile_file(file)
    end

    # Display success message after compilation completes
    println("\nSuccess! All .vm files were created.")
end

# Start program execution
main()