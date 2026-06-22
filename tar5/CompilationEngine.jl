# ====================================================================
# File: CompilationEngine.jl
# Role: Parses Jack source code and generates VM commands.
#       Uses the tokenizer, symbol table, and VM writer.
# ====================================================================

# Define the struct that manages the parsing operation and file writing
# Stores the current state of the compilation process.
# The engine connects the tokenizer, symbol table, and VM writer together.
mutable struct CompilationEngine
    tokenizer::Tokenizer          # Provides the current Jack token stream
    vm_writer::VMWriter           # Writes VM commands to the output file
    symbol_table::SymbolTable     # Stores class-scope and subroutine-scope identifiers
    class_name::String            # Current class name, used for full VM function names
    label_counter::Int            # Counter for creating unique labels
end

# Helper function (Constructor) to create a new engine instance
# Creates a new compilation engine for one Jack file.
# It opens the VM output file, creates a fresh symbol table, and loads the first token.
function create_engine(tokenizer::Tokenizer, output_path::String)
    writer = create_vm_writer(output_path)
    table = create_symbol_table()

    advance!(tokenizer)

    return CompilationEngine(tokenizer, writer, table, "", 0)
end

# Helper function to close the output file upon completion
# Closes the VM output file when compilation is finished.
function close_engine!(engine::CompilationEngine)
    close_vm_writer!(engine.vm_writer)
end



# Consumes a specific expected token and advances to the next token.
# If the token is not what the grammar expects, a syntax warning is printed.
function process!(engine::CompilationEngine, expected_token::String)
    if engine.tokenizer.current_token != expected_token
        println("Syntax error: expected '$(expected_token)' but found '$(engine.tokenizer.current_token)'")
    end

    advance!(engine.tokenizer)
end

# Consumes a token by expected token type and returns its value.
# This is used when the exact token value is not fixed, such as identifiers or constants.
function process_type!(engine::CompilationEngine, expected_type::String)
    if engine.tokenizer.token_type != expected_type
        println("Syntax error: expected type '$(expected_type)' but found '$(engine.tokenizer.token_type)'")
    end

    value = engine.tokenizer.current_token
    advance!(engine.tokenizer)
    return value
end


# Compiles a complete Jack class.
# Handles class-level variables first, then compiles all subroutines in the class.
function compile_class!(engine::CompilationEngine)
    process!(engine, "class")

    engine.class_name = process_type!(engine, IDENTIFIER)

    process!(engine, "{")

    while engine.tokenizer.current_token == "static" || engine.tokenizer.current_token == "field"
        compile_class_var_dec!(engine)
    end

    while engine.tokenizer.current_token == "constructor" ||
          engine.tokenizer.current_token == "function" ||
          engine.tokenizer.current_token == "method" ||
          engine.tokenizer.current_token == "procedure"
        compile_subroutine!(engine)
    end

    process!(engine, "}")
end


# Compiles class variable declarations: static and field variables.
# Each variable is added to the class-scope symbol table with its type, kind, and index.
function compile_class_var_dec!(engine::CompilationEngine)
    kind = engine.tokenizer.current_token
    process!(engine, kind)

    if engine.tokenizer.token_type == KEYWORD
        type = process_type!(engine, KEYWORD)
    else
        type = process_type!(engine, IDENTIFIER)
    end

    name = process_type!(engine, IDENTIFIER)
    define!(engine.symbol_table, name, type, kind)

    while engine.tokenizer.current_token == ","
        process!(engine, ",")
        name = process_type!(engine, IDENTIFIER)
        define!(engine.symbol_table, name, type, kind)
    end

    process!(engine, ";")
end

# Compiles a constructor, function, or method declaration.
# Starts a new subroutine scope and prepares the parameter list and body.
function compile_subroutine!(engine::CompilationEngine)
    start_subroutine!(engine.symbol_table)

    subroutine_kind = engine.tokenizer.current_token
    process!(engine, subroutine_kind)

    if subroutine_kind == "method"
        define!(engine.symbol_table, "this", engine.class_name, "argument")
    end

    if engine.tokenizer.current_token == "void"
        process!(engine, "void")
    elseif engine.tokenizer.token_type == KEYWORD
        process_type!(engine, KEYWORD)
    else
        process_type!(engine, IDENTIFIER)
    end

    subroutine_name = process_type!(engine, IDENTIFIER)

    process!(engine, "(")
    compile_parameter_list!(engine)
    process!(engine, ")")

    compile_subroutine_body!(engine, subroutine_kind, subroutine_name)
end

# Compiles the parameter list of a subroutine.
# Each parameter is saved as an argument in the subroutine-scope symbol table.
function compile_parameter_list!(engine::CompilationEngine)
    if engine.tokenizer.current_token != ")"
        if engine.tokenizer.token_type == KEYWORD
            type = process_type!(engine, KEYWORD)
        else
            type = process_type!(engine, IDENTIFIER)
        end

        name = process_type!(engine, IDENTIFIER)
        define!(engine.symbol_table, name, type, "argument")

        while engine.tokenizer.current_token == ","
            process!(engine, ",")

            if engine.tokenizer.token_type == KEYWORD
                type = process_type!(engine, KEYWORD)
            else
                type = process_type!(engine, IDENTIFIER)
            end

            name = process_type!(engine, IDENTIFIER)
            define!(engine.symbol_table, name, type, "argument")
        end
    end
end

# Compiles the body of a subroutine.
# Writes the VM function declaration and handles constructor/method setup code.
function compile_subroutine_body!(engine::CompilationEngine, subroutine_kind::String, subroutine_name::String)
    process!(engine, "{")

    while engine.tokenizer.current_token == "var"
        compile_var_dec!(engine)
    end

    full_name = engine.class_name * "." * subroutine_name
    n_locals = var_count(engine.symbol_table, "var")

    write_function!(engine.vm_writer, full_name, n_locals)

    if subroutine_kind == "constructor"
        fields_count = var_count(engine.symbol_table, "field")
        write_push!(engine.vm_writer, "constant", fields_count)
        write_call!(engine.vm_writer, "Memory.alloc", 1)
        write_pop!(engine.vm_writer, "pointer", 0)

    elseif subroutine_kind == "method"
        write_push!(engine.vm_writer, "argument", 0)
        write_pop!(engine.vm_writer, "pointer", 0)
    end

    compile_statements!(engine)

    process!(engine, "}")
end

# Compiles local variable declarations inside a subroutine.
# Each local variable is saved as kind "var" and later mapped to the VM local segment.
function compile_var_dec!(engine::CompilationEngine)
    process!(engine, "var")

    if engine.tokenizer.token_type == KEYWORD
        type = process_type!(engine, KEYWORD)
    else
        type = process_type!(engine, IDENTIFIER)
    end

    name = process_type!(engine, IDENTIFIER)
    define!(engine.symbol_table, name, type, "var")

    while engine.tokenizer.current_token == ","
        process!(engine, ",")
        name = process_type!(engine, IDENTIFIER)
        define!(engine.symbol_table, name, type, "var")
    end

    process!(engine, ";")
end

# Compiles a sequence of Jack statements until no statement keyword is found.
function compile_statements!(engine::CompilationEngine)
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
            break
        end
    end
end

# Compiles a let statement.
# Supports both simple assignments and array assignments.
function compile_let!(engine::CompilationEngine)
    process!(engine, "let")

    var_name = process_type!(engine, IDENTIFIER)
    kind = kind_of(engine.symbol_table, var_name)
    segment = kind_to_segment(kind)
    index = index_of(engine.symbol_table, var_name)

    is_array = false

    if engine.tokenizer.current_token == "["
        is_array = true

        write_push!(engine.vm_writer, segment, index)

        process!(engine, "[")
        compile_expression!(engine)
        process!(engine, "]")

        write_arithmetic!(engine.vm_writer, "add")
    end

    process!(engine, "=")
    compile_expression!(engine)
    process!(engine, ";")

    if is_array
        write_pop!(engine.vm_writer, "temp", 0)
        write_pop!(engine.vm_writer, "pointer", 1)
        write_push!(engine.vm_writer, "temp", 0)
        write_pop!(engine.vm_writer, "that", 0)
    else
        write_pop!(engine.vm_writer, segment, index)
    end
end


# Compiles a subroutine call and writes the matching VM call command.
# Handles method calls on the current object, method calls on another object, and static function calls.
function compile_subroutine_call!(engine::CompilationEngine, first_name::String)
    n_args = 0

    if engine.tokenizer.current_token == "."
        process!(engine, ".")

        second_name = process_type!(engine, IDENTIFIER)

        if kind_of(engine.symbol_table, first_name) != "none"
            kind = kind_of(engine.symbol_table, first_name)
            segment = kind_to_segment(kind)
            index = index_of(engine.symbol_table, first_name)
            type = type_of(engine.symbol_table, first_name)

            write_push!(engine.vm_writer, segment, index)
            n_args += 1

            full_name = type * "." * second_name
        else
            full_name = first_name * "." * second_name
        end
    else
        write_push!(engine.vm_writer, "pointer", 0)
        n_args += 1

        full_name = engine.class_name * "." * first_name
    end

    process!(engine, "(")
    n_args += compile_expression_list!(engine)
    process!(engine, ")")

    write_call!(engine.vm_writer, full_name, n_args)
end


# Compiles a do statement.
# Since do statements ignore the return value, the returned value is popped into temp 0.
function compile_do!(engine::CompilationEngine)
    process!(engine, "do")

    # New command: do { statements } while (expression);
    if engine.tokenizer.current_token == "{"
        start_label = new_label!(engine, "DO_WHILE_EXP")

        write_label!(engine.vm_writer, start_label)

        process!(engine, "{")
        compile_statements!(engine)
        process!(engine, "}")

        process!(engine, "while")
        process!(engine, "(")
        compile_expression!(engine)
        process!(engine, ")")
        process!(engine, ";")

        write_if!(engine.vm_writer, start_label)

    # Existing command: do subroutineCall;
    else
        first_name = process_type!(engine, IDENTIFIER)
        compile_subroutine_call!(engine, first_name)

        write_pop!(engine.vm_writer, "temp", 0)

        process!(engine, ";")
    end
end

# Compiles a return statement.
# For void returns, pushes constant 0 because every VM function must return a value.
function compile_return!(engine::CompilationEngine)
    process!(engine, "return")

    if engine.tokenizer.current_token != ";"
        compile_expression!(engine)
    else
        write_push!(engine.vm_writer, "constant", 0)
    end

    write_return!(engine.vm_writer)

    process!(engine, ";")
end

# Creates a unique VM label using a prefix and a running counter.
# Used by if and while statements to avoid duplicate labels.
function new_label!(engine::CompilationEngine, prefix::String)
    label = prefix * string(engine.label_counter)
    engine.label_counter += 1
    return label
end

# Compiles a while statement using VM labels and conditional branching.
function compile_while!(engine::CompilationEngine)
    start_label = new_label!(engine, "WHILE_EXP")
    end_label = new_label!(engine, "WHILE_END")

    write_label!(engine.vm_writer, start_label)

    process!(engine, "while")
    process!(engine, "(")
    compile_expression!(engine)
    process!(engine, ")")

    write_arithmetic!(engine.vm_writer, "not")
    write_if!(engine.vm_writer, end_label)

    process!(engine, "{")
    compile_statements!(engine)
    process!(engine, "}")

    write_goto!(engine.vm_writer, start_label)
    write_label!(engine.vm_writer, end_label)
end

# Compiles an if statement, including an optional else block.
# Uses generated labels to control the VM branching flow.
function compile_if!(engine::CompilationEngine)
    true_label = new_label!(engine, "IF_TRUE")
    false_label = new_label!(engine, "IF_FALSE")
    end_label = new_label!(engine, "IF_END")

    process!(engine, "if")
    process!(engine, "(")
    compile_expression!(engine)
    process!(engine, ")")

    write_if!(engine.vm_writer, true_label)
    write_goto!(engine.vm_writer, false_label)
    write_label!(engine.vm_writer, true_label)

    process!(engine, "{")
    compile_statements!(engine)
    process!(engine, "}")

    if engine.tokenizer.current_token == "else"
        write_goto!(engine.vm_writer, end_label)
        write_label!(engine.vm_writer, false_label)

        process!(engine, "else")
        process!(engine, "{")
        compile_statements!(engine)
        process!(engine, "}")

        write_label!(engine.vm_writer, end_label)
    else
        write_label!(engine.vm_writer, false_label)
    end
end
# ====================================================================
# Final grammar rules for expressions, terms, and input lists
# ====================================================================

# Compiles an expression: term (operator term)*.
# Each operator is translated into the matching VM arithmetic command or OS call.
function compile_expression!(engine::CompilationEngine)
    compile_term!(engine)

    ops = ["+", "-", "*", "/", "&amp;", "|", "&lt;", "&gt;", "=", raw"$"]

    while in(engine.tokenizer.current_token, ops)
        op = engine.tokenizer.current_token
        process!(engine, op)

        compile_term!(engine)

        if op == "+" || op == raw"$"
            write_arithmetic!(engine.vm_writer, "add")
        elseif op == "-"
            write_arithmetic!(engine.vm_writer, "sub")
        elseif op == "*"
            write_call!(engine.vm_writer, "Math.multiply", 2)
        elseif op == "/"
            write_call!(engine.vm_writer, "Math.divide", 2)
        elseif op == "&amp;"
            write_arithmetic!(engine.vm_writer, "and")
        elseif op == "|"
            write_arithmetic!(engine.vm_writer, "or")
        elseif op == "&lt;"
            write_arithmetic!(engine.vm_writer, "lt")
        elseif op == "&gt;"
            write_arithmetic!(engine.vm_writer, "gt")
        elseif op == "="
            write_arithmetic!(engine.vm_writer, "eq")
        end
    end
end

# Compiles a single term in an expression.
# Supports constants, variables, arrays, strings, unary operations, nested expressions, and subroutine calls.
function compile_term!(engine::CompilationEngine)
    token_type = engine.tokenizer.token_type
    token = engine.tokenizer.current_token

    if token_type == INT_CONST
        value = parse(Int, process_type!(engine, INT_CONST))
        write_push!(engine.vm_writer, "constant", value)

    elseif token_type == STRING_CONST
        value = process_type!(engine, STRING_CONST)
        write_push!(engine.vm_writer, "constant", length(value))
        write_call!(engine.vm_writer, "String.new", 1)

        for ch in value
            write_push!(engine.vm_writer, "constant", Int(ch))
            write_call!(engine.vm_writer, "String.appendChar", 2)
        end

    elseif token_type == KEYWORD && token == "true"
        process!(engine, "true")
        write_push!(engine.vm_writer, "constant", 0)
        write_arithmetic!(engine.vm_writer, "not")

    elseif token_type == KEYWORD && (token == "false" || token == "null")
        process!(engine, token)
        write_push!(engine.vm_writer, "constant", 0)

    elseif token_type == KEYWORD && token == "this"
        process!(engine, "this")
        write_push!(engine.vm_writer, "pointer", 0)

    elseif token == "("
        process!(engine, "(")
        compile_expression!(engine)
        process!(engine, ")")

    elseif token == "-" || token == "~"
        unary_op = token
        process!(engine, unary_op)
        compile_term!(engine)

        if unary_op == "-"
            write_arithmetic!(engine.vm_writer, "neg")
        else
            write_arithmetic!(engine.vm_writer, "not")
        end

    elseif token_type == IDENTIFIER
        name = process_type!(engine, IDENTIFIER)

        if engine.tokenizer.current_token == "(" || engine.tokenizer.current_token == "."
            compile_subroutine_call!(engine, name)
        elseif engine.tokenizer.current_token == "["
            kind = kind_of(engine.symbol_table, name)
            segment = kind_to_segment(kind)
            index = index_of(engine.symbol_table, name)

            write_push!(engine.vm_writer, segment, index)

            process!(engine, "[")
            compile_expression!(engine)
            process!(engine, "]")

            write_arithmetic!(engine.vm_writer, "add")
            write_pop!(engine.vm_writer, "pointer", 1)
            write_push!(engine.vm_writer, "that", 0)

        else
            kind = kind_of(engine.symbol_table, name)
            segment = kind_to_segment(kind)
            index = index_of(engine.symbol_table, name)

            write_push!(engine.vm_writer, segment, index)
        end
    end
end

# Compiles a comma-separated expression list.
# Returns the number of expressions compiled, which is the number of VM arguments pushed.
function compile_expression_list!(engine::CompilationEngine)
    count = 0

    if engine.tokenizer.current_token != ")"
        compile_expression!(engine)
        count += 1

        while engine.tokenizer.current_token == ","
            process!(engine, ",")
            compile_expression!(engine)
            count += 1
        end
    end

    return count
end