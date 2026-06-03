# ====================================================================
# File: CompilationEngine.jl
# Role: The complete syntax analyzer (Parser) that processes the token
#       stream and generates a hierarchical, valid XML parse tree
#       (supports expressions and arrays) with exact indentation.
# ====================================================================

# Define the struct that manages the parsing operation and file writing
mutable struct CompilationEngine
    tokenizer::Tokenizer     # Reference to our active tokenizer
    output_file::IOStream    # The main XML file we are writing to
    indent_level::Int        # Tracks current indentation level for XML output
end

# Helper function (Constructor) to create a new engine instance
function create_engine(tokenizer::Tokenizer, output_path::String)
    out = open(output_path, "w")
    # Pre-load the first token of the file
    advance!(tokenizer)
    return CompilationEngine(tokenizer, out, 0)
end

# Helper function to close the output file upon completion
function close_engine!(engine::CompilationEngine)
    close(engine.output_file)
end

# Helper function to generate string of spaces based on current indent level
function get_indent(engine::CompilationEngine)
    return repeat("  ", engine.indent_level)
end

# Core critical function: validates match, prints terminal to XML, and advances to the next token
function process!(engine::CompilationEngine, expected_token::String)
    # If the current token matches what the grammar rule requires
    if engine.tokenizer.current_token == expected_token
        # Print the terminal token to the XML file with proper indentation
        write(engine.output_file, "$(get_indent(engine))<$(engine.tokenizer.token_type)> $(engine.tokenizer.current_token) </$(engine.tokenizer.token_type)>\n")
        # Advance the tokenizer to the next token in line
        advance!(engine.tokenizer)
    else
        # Note: Guidelines specify no syntax error handling is required, but an alert is printed to console just in case
        println("Syntax error: expected '$(expected_token)' but found '$(engine.tokenizer.current_token)'")
        # Still write and advance to avoid getting stuck
        write(engine.output_file, "$(get_indent(engine))<$(engine.tokenizer.token_type)> $(engine.tokenizer.current_token) </$(engine.tokenizer.token_type)>\n")
        advance!(engine.tokenizer)
    end
end

# Helper function to print a general token (when its value changes, e.g., identifiers or constants)
function process_type!(engine::CompilationEngine, expected_type::String)
    if engine.tokenizer.token_type == expected_type
        write(engine.output_file, "$(get_indent(engine))<$(engine.tokenizer.token_type)> $(engine.tokenizer.current_token) </$(engine.tokenizer.token_type)>\n")
        advance!(engine.tokenizer)
    else
        println("Syntax error: expected type '$(expected_type)' but found '$(engine.tokenizer.token_type)'")
        write(engine.output_file, "$(get_indent(engine))<$(engine.tokenizer.token_type)> $(engine.tokenizer.current_token) </$(engine.tokenizer.token_type)'")
        advance!(engine.tokenizer)
    end
end

# Grammar rule: compileClass
# 'class' className '{' classVarDec* subroutineDec* '}'
function compile_class!(engine::CompilationEngine)
    # 1. Write the opening tag for the class rule
    write(engine.output_file, "$(get_indent(engine))<class>\n")
    engine.indent_level += 1

    # 2. Process initial terminals: class className {
    process!(engine, "class")
    process_type!(engine, IDENTIFIER)  # className is an identifier
    process!(engine, "{")

    # 3. Loop for classVarDec* (zero or more)
    # Tag is opened only if class variables actually exist in the code
    while engine.tokenizer.current_token == "static" || engine.tokenizer.current_token == "field"
        compile_class_var_dec!(engine)
    end

    # 4. Loop for subroutineDec* (zero or more)
    while engine.tokenizer.current_token == "constructor" ||
          engine.tokenizer.current_token == "function" ||
          engine.tokenizer.current_token == "method"
        compile_subroutine!(engine)
    end

    # 5. Process the closing terminal: }
    process!(engine, "}")

    # 6. Write the closing tag for the class rule
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</class>\n")
end

# Grammar rule: compileClassVarDec
# ('static' | 'field') type varName (',' varName)* ';'
function compile_class_var_dec!(engine::CompilationEngine)
    # 1. Open the rule tag (only opened when a variable exists, as per instructions)
    write(engine.output_file, "$(get_indent(engine))<classVarDec>\n")
    engine.indent_level += 1

    # 2. Process the first terminal: 'static' or 'field'
    if engine.tokenizer.current_token == "static" || engine.tokenizer.current_token == "field"
        process!(engine, engine.tokenizer.current_token)
    end

    # 3. Process the type (can be a keyword like int/char/boolean or a class name identifier)
    if engine.tokenizer.token_type == KEYWORD
        process_type!(engine, KEYWORD)
    else
        process_type!(engine, IDENTIFIER)
    end

    # 4. Process the first variable name (varName)
    process_type!(engine, IDENTIFIER)

    # 5. Loop for additional comma-separated variables: (',' varName)*
    while engine.tokenizer.current_token == ","
        process!(engine, ",")             # Process the comma
        process_type!(engine, IDENTIFIER)  # Process the next variable name
    end

    # 6. Process the terminating semicolon: ';'
    process!(engine, ";")

    # 7. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</classVarDec>\n")
end

# Grammar rule: compileSubroutine
# ('constructor' | 'function' | 'method') ('void' | type) subroutineName '(' parameterList ')' subroutineBody
function compile_subroutine!(engine::CompilationEngine)
    # 1. Open the rule tag
    write(engine.output_file, "$(get_indent(engine))<subroutineDec>\n")
    engine.indent_level += 1

    # 2. Process the first terminal: 'constructor' / 'function' / 'method'
    process!(engine, engine.tokenizer.current_token)

    # 3. Process the return type: 'void' or a data type (type)
    if engine.tokenizer.current_token == "void"
        process!(engine, "void")
    elseif engine.tokenizer.token_type == KEYWORD
        process_type!(engine, KEYWORD)
    else
        process_type!(engine, IDENTIFIER)
    end

    # 4. Process the subroutine name (subroutineName)
    process_type!(engine, IDENTIFIER)

    # 5. Process the opening parenthesis of the parameter list: '('
    process!(engine, "(")

    # 6. Call the parameter list compilation rule (parameterList)
    compile_parameter_list!(engine)

    # 7. Process the closing parenthesis of the parameter list: ')'
    process!(engine, ")")

    # 8. Call the subroutine body compilation rule (subroutineBody)
    compile_subroutine_body!(engine)

    # 9. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</subroutineDec>\n")
end

# Grammar rule: compileParameterList
# ((type varName) (',' type varName)*)?
function compile_parameter_list!(engine::CompilationEngine)
    # Important note: Open and close the tag in all cases, even if the list is empty!
    write(engine.output_file, "$(get_indent(engine))<parameterList>\n")
    engine.indent_level += 1

    # Check if there are parameters (if current token is a known data type keyword or class name identifier)
    # The parameter list terminates when the closing parenthesis ')' is encountered
    if engine.tokenizer.current_token != ")"
        # Process the data type of the first parameter
        if engine.tokenizer.token_type == KEYWORD
            process_type!(engine, KEYWORD)
        else
            process_type!(engine, IDENTIFIER)
        end
        # Process the name of the first parameter
        process_type!(engine, IDENTIFIER)

        # Loop for additional comma-separated parameters: (',' type varName)*
        while engine.tokenizer.current_token == ","
            process!(engine, ",") # Process the comma

            # Process the data type of the next parameter
            if engine.tokenizer.token_type == KEYWORD
                process_type!(engine, KEYWORD)
            else
                process_type!(engine, IDENTIFIER)
            end

            # Process the name of the next parameter
            process_type!(engine, IDENTIFIER)
        end
    end

    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</parameterList>\n")
end

# Grammar rule: compileSubroutineBody
# '{' varDec* statements '}'
function compile_subroutine_body!(engine::CompilationEngine)
    # 1. Open the rule tag
    write(engine.output_file, "$(get_indent(engine))<subroutineBody>\n")
    engine.indent_level += 1

    # 2. Process the opening curly brace: '{'
    process!(engine, "{")

    # 3. Loop for varDec* (zero or more)
    # Local variable tag will open inside the function only if the word 'var' actually exists!
    while engine.tokenizer.current_token == "var"
        compile_var_dec!(engine)
    end

    # 4. Call the statements compilation rule (statements)
    compile_statements!(engine)

    # 5. Process the closing curly brace: '}'
    process!(engine, "}")

    # 6. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</subroutineBody>\n")
end

# Grammar rule: compileVarDec
# 'var' type varName (',' varName)* ';'
function compile_var_dec!(engine::CompilationEngine)
    # Open the rule tag (only opened when variables exist, as per instructions)
    write(engine.output_file, "$(get_indent(engine))<varDec>\n")
    engine.indent_level += 1

    # 1. Process the reserved word: 'var'
    process!(engine, "var")

    # 2. Process the type (keyword like int/char/boolean or a class name identifier)
    if engine.tokenizer.token_type == KEYWORD
        process_type!(engine, KEYWORD)
    else
        process_type!(engine, IDENTIFIER)
    end

    # 3. Process the name of the first local variable
    process_type!(engine, IDENTIFIER)

    # 4. Loop for additional variables on the same line separated by commas: (',' varName)*
    while engine.tokenizer.current_token == ","
        process!(engine, ",")
        process_type!(engine, IDENTIFIER)
    end

    # 5. Process the terminating semicolon: ';'
    process!(engine, ";")

    # 6. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</varDec>\n")
end

# Grammar rule: compileStatements
# statement*
function compile_statements!(engine::CompilationEngine)
    # 1. Open the wrapper tag for the statements list
    write(engine.output_file, "$(get_indent(engine))<statements>\n")
    engine.indent_level += 1

    # 2. Loop that runs as long as the current token represents the start of a valid Jack statement
    while true
        token = engine.tokenizer.current_token

        if token == "let"
            compile_let!(engine)
        elseif token == "if"
            compile_if!(engine)
        elseif token == "while"
            compile_while!(engine)
        elseif token == "do"
            compile_do!(engine)
        elseif token == "return"
            compile_return!(engine)
        else
            # If another character is encountered (e.g., '}' that terminates the block), exit the loop
            break
        end
    end

    # 3. Close the wrapper tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</statements>\n")
end

# Grammar rule: compileLet
# 'let' varName ('[' expression ']')? '=' expression ';'
function compile_let!(engine::CompilationEngine)
    # 1. Open the rule tag
    write(engine.output_file, "$(get_indent(engine))<letStatement>\n")
    engine.indent_level += 1

    # 2. Process the reserved word 'let' and the variable name
    process!(engine, "let")
    process_type!(engine, IDENTIFIER)

    # 3. Optional array handling: ('[' expression ']')?
    if engine.tokenizer.current_token == "["
        process!(engine, "[")
        compile_expression!(engine) # Call the expression compilation rule for the array index
        process!(engine, "]")
    end

    # 4. Process the equals sign '='
    process!(engine, "=")

    # 5. Process the expression on the right-hand side - call the full expression mechanism
    compile_expression!(engine)

    # 6. Process the semicolon ';'
    process!(engine, ";")

    # 7. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</letStatement>\n")
end

# Grammar rule: compileDo
# 'do' subroutineCall ';'
function compile_do!(engine::CompilationEngine)
    # 1. Open the rule tag
    write(engine.output_file, "$(get_indent(engine))<doStatement>\n")
    engine.indent_level += 1

    # 2. Process the reserved word 'do'
    process!(engine, "do")

    # 3. Process the subroutineCall (without a dedicated wrapper tag, as per instructions)
    process_type!(engine, IDENTIFIER)

    # Check if this is a call using a dot notation (ClassName.subroutineName or varName.subroutineName)
    if engine.tokenizer.current_token == "."
        process!(engine, ".")              # Process the dot
        process_type!(engine, IDENTIFIER)  # Process the actual subroutine name
    end

    # Process the opening parenthesis of the subroutine call input expressions
    process!(engine, "(")

    # Call the actual expression list rule for the subroutine parameters
    compile_expression_list!(engine)

    # Process the closing parenthesis of the expressions list ')'
    process!(engine, ")")

    # 4. Process the terminating semicolon ';'
    process!(engine, ";")

    # 5. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</doStatement>\n")
end

# Grammar rule: compileReturn
# 'return' expression? ';'
function compile_return!(engine::CompilationEngine)
    # 1. Open the rule tag
    write(engine.output_file, "$(get_indent(engine))<returnStatement>\n")
    engine.indent_level += 1

    # 2. Process the reserved word 'return'
    process!(engine, "return")

    # 3. Check if a return expression exists (if current token is not ';')
    if engine.tokenizer.current_token != ";"
        compile_expression!(engine) # Call the expression rule for the returned value
    end

    # 4. Process the semicolon ';'
    process!(engine, ";")

    # 5. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</returnStatement>\n")
end

# Grammar rule: compileWhile
# 'while' '(' expression ')' '{' statements '}'
function compile_while!(engine::CompilationEngine)
    # 1. Open the rule tag
    write(engine.output_file, "$(get_indent(engine))<whileStatement>\n")
    engine.indent_level += 1

    # 2. Process initial terminals: while (
    process!(engine, "while")
    process!(engine, "(")

    # 3. Process the condition using the full expression grammar rule
    compile_expression!(engine)

    # 4. Process closing parenthesis and opening curly brace: ) {
    process!(engine, ")")
    process!(engine, "{")

    # 5. Recursive call to process the statement list inside the loop
    compile_statements!(engine)

    # 6. Process the closing curly brace: }
    process!(engine, "}")

    # 7. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</whileStatement>\n")
end

# Grammar rule: compileIf
# 'if' '(' expression ')' '{' statements '}' ('else' '{' statements '}')?
function compile_if!(engine::CompilationEngine)
    # 1. Open the rule tag
    write(engine.output_file, "$(get_indent(engine))<ifStatement>\n")
    engine.indent_level += 1

    # 2. Process initial terminals: if (
    process!(engine, "if")
    process!(engine, "(")

    # 3. Process the condition using the full expression grammar rule
    compile_expression!(engine)

    # 4. Process closing parenthesis and opening curly brace of the if-block: ) {
    process!(engine, ")")
    process!(engine, "{")

    # 5. Recursive call to process the statement list of the if-block
    compile_statements!(engine)

    # 6. Process the closing curly brace of the if-block: }
    process!(engine, "}")

    # 7. Check if an optional 'else' block exists
    if engine.tokenizer.current_token == "else"
        process!(engine, "else")
        process!(engine, "{")

        # Recursive call to process the statement list of the else-block
        compile_statements!(engine)

        process!(engine, "}")
    end

    # 8. Close the rule tag
    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</ifStatement>\n")
end

# ====================================================================
# Final grammar rules for expressions, terms, and input lists
# ====================================================================

# Grammar rule: compileExpression
# term (op term)*
function compile_expression!(engine::CompilationEngine)
    write(engine.output_file, "$(get_indent(engine))<expression>\n")
    engine.indent_level += 1

    compile_term!(engine)

    # Valid operators in the Jack language matching XML-escaped format correctly
    ops = ["+", "-", "*", "/", "&amp;", "|", "&lt;", "&gt;", "="]
    while in(engine.tokenizer.current_token, ops)
        process!(engine, engine.tokenizer.current_token)
        compile_term!(engine)
    end

    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</expression>\n")
end

# Grammar rule: compileTerm
# integerConstant | stringConstant | keywordConstant | varName |
# varName '[' expression ']' | subroutineCall | '(' expression ')' | unaryOp term
function compile_term!(engine::CompilationEngine)
    write(engine.output_file, "$(get_indent(engine))<term>\n")
    engine.indent_level += 1

    token_type = engine.tokenizer.token_type
    token = engine.tokenizer.current_token

    if token_type == INT_CONST
        process_type!(engine, INT_CONST)
    elseif token_type == STRING_CONST
        process_type!(engine, STRING_CONST)
    elseif token_type == KEYWORD && (token == "true" || token == "false" || token == "null" || token == "this")
        process_type!(engine, KEYWORD)
    elseif token == "("
        process!(engine, "(")
        compile_expression!(engine)
        process!(engine, ")")
    elseif token == "-" || token == "~"
        process!(engine, token)
        compile_term!(engine)
    elseif token_type == IDENTIFIER
        # Process the main identifier first (variable name, class name, or subroutine name)
        process_type!(engine, IDENTIFIER)

        # LL(2) Lookahead check after advancing past the identifier
        if engine.tokenizer.current_token == "["
            process!(engine, "[")
            compile_expression!(engine)
            process!(engine, "]")
        elseif engine.tokenizer.current_token == "("
            process!(engine, "(")
            compile_expression_list!(engine)
            process!(engine, ")")
        elseif engine.tokenizer.current_token == "."
            process!(engine, ".")
            process_type!(engine, IDENTIFIER) # Process the subroutine name after the dot
            process!(engine, "(")
            compile_expression_list!(engine)
            process!(engine, ")")
        end
    end

    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</term>\n")
end

# Grammar rule: compileExpressionList
# (expression (',' expression)*)?
function compile_expression_list!(engine::CompilationEngine)
    write(engine.output_file, "$(get_indent(engine))<expressionList>\n")
    engine.indent_level += 1

    # An expression list always terminates when the closing parenthesis ')' is encountered
    if engine.tokenizer.current_token != ")"
        compile_expression!(engine)
        while engine.tokenizer.current_token == ","
            process!(engine, ",")
            compile_expression!(engine)
        end
    end

    engine.indent_level -= 1
    write(engine.output_file, "$(get_indent(engine))</expressionList>\n")
end