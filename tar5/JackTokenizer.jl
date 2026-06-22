# ====================================================================
# File: JackTokenizer.jl
# Role: Deconstructs Jack source code into basic tokens (syntactic atoms).
# ====================================================================

# 1. Define possible token types as constants
const KEYWORD         = "keyword"
const SYMBOL          = "symbol"
const IDENTIFIER      = "identifier"
const INT_CONST       = "integerConstant"
const STRING_CONST    = "stringConstant"

# 2. Groups of reserved keywords and defined symbols in Jack (per book and presentation)
const JACK_KEYWORDS = Set([
    "class", "constructor", "function", "method", "field", "static", "var",
    "int", "char", "boolean", "void", "true", "false", "null", "this",
    "let", "do", "if", "else", "while", "return", "procedure"
])

const JACK_SYMBOLS = Set([
    '{', '}', '(', ')', '[', ']', '.', ',', ';',
    '+', '-', '*', '/', '&', '|', '<', '>', '=', '~', '$'
])

# 3. Data structure to manage the tokenizer state (holds text, position, and current token)
mutable struct Tokenizer
    source_code::String       # Entire Jack source code as one large string
    pos::Int                  # Current scan position (character index)
    current_token::String     # The current word or symbol identified
    token_type::String        # The type of the current token (e.g., "keyword" or "symbol")
end

# Helper function (Constructor) to build a new tokenizer from a file path
function create_tokenizer(file_path::String)
    # Read entire file content and load it into a single string
    content = read(file_path, String)
    return Tokenizer(content, 1, "", "")
end

# Helper function to check if we reached the end of the file
function has_more_chars(tokenizer::Tokenizer)
    return tokenizer.pos <= length(tokenizer.source_code)
end

# Helper function that returns the current character without advancing the index
function peek_char(tokenizer::Tokenizer)
    if !has_more_chars(tokenizer)
        return '\0'
    end
    return tokenizer.source_code[tokenizer.pos]
end

# Helper function that returns the next character (one ahead) without advancing the index
function peek_next_char(tokenizer::Tokenizer)
    if tokenizer.pos + 1 > length(tokenizer.source_code)
        return '\0'
    end
    return tokenizer.source_code[tokenizer.pos + 1]
end

# Function that advances the cursor by one character and returns it
function read_char!(tokenizer::Tokenizer)
    c = peek_char(tokenizer)
    tokenizer.pos += 1
    return c
end

# Critical function: skips all whitespaces, newlines, and comments (// and /*)
function skip_whitespace_and_comments!(tokenizer::Tokenizer)
    while has_more_chars(tokenizer)
        c = peek_char(tokenizer)

        # 1. Skip spaces, tabs, and line breaks
        if c == ' ' || c == '\t' || c == '\r' || c == '\n'
            read_char!(tokenizer)

        # 2. Check if it is a comment (starts with /)
        elseif c == '/'
            next_c = peek_next_char(tokenizer)

            if next_c == '/'  # Single-line comment: //
                # Read both slashes
                read_char!(tokenizer)
                read_char!(tokenizer)
                # Run until the end of the line
                while has_more_chars(tokenizer) && peek_char(tokenizer) != '\n'
                    read_char!(tokenizer)
                end

            elseif next_c == '*'  # Block comment: /* or /**
                # Read the / and the *
                read_char!(tokenizer)
                read_char!(tokenizer)
                # Run until */ is found
                found_end = false
                while has_more_chars(tokenizer) && !found_end
                    if peek_char(tokenizer) == '*' && peek_next_char(tokenizer) == '/'
                        read_char!(tokenizer) # Read the *
                        read_char!(tokenizer) # Read the /
                        found_end = true
                    else
                        read_char!(tokenizer)
                    end
                end
            else
                # This is not the start of a comment, but a single division symbol '/'! Stop here and let the state machine handle it
                break
            end
        else
            # Reached a character that is neither whitespace nor a comment - stop cleaning
            break
        end
    end
end

# Helper function to convert special characters for XML compatibility
function escape_xml_symbol(symbol_str::String)
    if symbol_str == "<"  return "&lt;"  end
    if symbol_str == ">"  return "&gt;"  end
    if symbol_str == "\"" return "&quot;" end
    if symbol_str == "&"  return "&amp;"  end
    return symbol_str
end

# Main function: reads the next token and updates the tokenizer state
function advance!(tokenizer::Tokenizer)
    # 1. First, skip whitespace and comments to reach the next actual character
    skip_whitespace_and_comments!(tokenizer)

    # If we reached the end of the file, there is nothing to read
    if !has_more_chars(tokenizer)
        tokenizer.current_token = ""
        tokenizer.token_type = ""
        return
    end

    # Peek at the next character in the state machine
    c = peek_char(tokenizer)

    # --- Case A: Digit (integerConstant) ---
    if isdigit(c)
        temp = ""
        # Continue running and accumulating as long as it is a digit
        while has_more_chars(tokenizer) && isdigit(peek_char(tokenizer))
            temp *= read_char!(tokenizer)
        end
        tokenizer.current_token = temp
        tokenizer.token_type = INT_CONST

    # --- Case B: Quote (stringConstant) ---
    elseif c == '"'
        read_char!(tokenizer) # Discard the opening quote
        temp = ""
        # Continue running and accumulating until we see another quote
        while has_more_chars(tokenizer) && peek_char(tokenizer) != '"'
            temp *= read_char!(tokenizer)
        end
        read_char!(tokenizer) # Discard the closing quote
        tokenizer.current_token = temp
        tokenizer.token_type = STRING_CONST

    # --- Case C: Symbol (symbol) ---
    elseif c in JACK_SYMBOLS
        # Read the symbol (a symbol is always a single character)
        symbol_char = read_char!(tokenizer)
        symbol_str = string(symbol_char)

        # Convert special characters to valid XML format
        tokenizer.current_token = escape_xml_symbol(symbol_str)
        tokenizer.token_type = SYMBOL

    # --- Case D: Letter or underscore (keyword / identifier) ---
    elseif isletter(c) || c == '_'
        temp = ""
        # Run as long as it is a letter, underscore, or digit
        while has_more_chars(tokenizer) && (isletter(peek_char(tokenizer)) || isdigit(peek_char(tokenizer)) || peek_char(tokenizer) == '_')
            temp *= read_char!(tokenizer)
        end

        tokenizer.current_token = temp
        # Check if the accumulated word is a reserved keyword
        if temp in JACK_KEYWORDS
            tokenizer.token_type = KEYWORD
        else
            tokenizer.token_type = IDENTIFIER
        end
    else
        # Just in case an unrecognized character is encountered, advance to avoid an infinite loop
        read_char!(tokenizer)
    end
end