# ====================================================================
# File: JackAnalyzer.jl
# Role: The main program that requests a directory path as input from
#       the user, and automatically runs both analysis stages
#       (Part A and Part B) sequentially.
# ====================================================================

include("JackTokenizer.jl")
include("CompilationEngine.jl")

# Function that handles Part A - creating the flat tokens file (xxx0T.xml)
function analyze_file_tokenizing(jack_file_path::String)
    # Adding 0 to the filename to prevent overwriting source and test files
    output_file_path = replace(jack_file_path, ".jack" => "0T.xml")

    println("Executing Tokenizing for file: ", jack_file_path, " -> Generating: ", output_file_path)

    tokenizer = create_tokenizer(jack_file_path)

    open(output_file_path, "w") do out
        write(out, "<tokens>\n")

        advance!(tokenizer)
        while tokenizer.current_token != ""
            write(out, "<$(tokenizer.token_type)> $(tokenizer.current_token) </$(tokenizer.token_type)>\n")
            advance!(tokenizer)
        end

        write(out, "</tokens>\n")
    end
end

# Function that handles Part B - creating the full parse tree file (xxx0.xml)
function analyze_file_parsing(jack_file_path::String)
    # Adding 0 to the filename to prevent overwriting source and test files
    output_file_path = replace(jack_file_path, ".jack" => "0.xml")

    println("Executing Parsing for file: ", jack_file_path, " -> Generating: ", output_file_path)

    tokenizer = create_tokenizer(jack_file_path)
    engine = create_engine(tokenizer, output_file_path)

    # Start the recursive parsing process from the main Class level
    compile_class!(engine)

    close_engine!(engine)
end

# The main function of the compiler
function main()
    # Requesting the directory path from the user during runtime
    print("Please enter the path of the directory you wish to process: ")
    dir_path = strip(readline())

    # Check if the specified directory path exists
    if !isdir(dir_path)
        println("Error: The specified directory does not exist! Please try again.")
        return
    end

    all_files = readdir(dir_path, join=true)
    jack_files = filter(f -> endswith(f, ".jack"), all_files)

    if isempty(jack_files)
        println("No .jack files were found in the specified directory.")
        return
    end

    # Executing both stages sequentially for each file
    for file in jack_files
        analyze_file_tokenizing(file)  # Part A - Tokenizing
        analyze_file_parsing(file)     # Part B - Parsing
    end

    println("\n✨ Success! All 0T.xml and 0.xml files were created sequentially without overwriting source files.")
end

# Call the main function to start the program execution immediately
main()