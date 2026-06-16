# ====================================================================
# File: SymbolTable.jl
# Role: Manages Jack variables in class scope and subroutine scope.
# ====================================================================

# Stores information about a single identifier:
# its type, kind, and running index
mutable struct SymbolInfo
    type::String
    kind::String
    index::Int
end

# Maintains symbol tables for class-level and subroutine-level identifiers,
# along with counters for each identifier kind
mutable struct SymbolTable
    class_scope::Dict{String, SymbolInfo}
    subroutine_scope::Dict{String, SymbolInfo}
    static_count::Int
    field_count::Int
    argument_count::Int
    var_count::Int
end

# Creates and initializes an empty symbol table
function create_symbol_table()
    return SymbolTable(Dict(), Dict(), 0, 0, 0, 0)
end

# Starts a new subroutine scope by clearing local identifiers
# and resetting argument/local variable counters
function start_subroutine!(table::SymbolTable)
    empty!(table.subroutine_scope)
    table.argument_count = 0
    table.var_count = 0
end

# Adds a new identifier to the appropriate scope
# and assigns it a running index according to its kind
function define!(table::SymbolTable, name::String, type::String, kind::String)
    if kind == "static"
        table.class_scope[name] = SymbolInfo(type, kind, table.static_count)
        table.static_count += 1
    elseif kind == "field"
        table.class_scope[name] = SymbolInfo(type, kind, table.field_count)
        table.field_count += 1
    elseif kind == "argument"
        table.subroutine_scope[name] = SymbolInfo(type, kind, table.argument_count)
        table.argument_count += 1
    elseif kind == "var"
        table.subroutine_scope[name] = SymbolInfo(type, kind, table.var_count)
        table.var_count += 1
    end
end

# Returns the number of identifiers currently defined
# for the requested kind
function var_count(table::SymbolTable, kind::String)
    if kind == "static"
        return table.static_count
    elseif kind == "field"
        return table.field_count
    elseif kind == "argument"
        return table.argument_count
    elseif kind == "var"
        return table.var_count
    end
    return 0
end

# Returns the kind of the specified identifier
# Searches subroutine scope before class scope
function kind_of(table::SymbolTable, name::String)
    if haskey(table.subroutine_scope, name)
        return table.subroutine_scope[name].kind
    elseif haskey(table.class_scope, name)
        return table.class_scope[name].kind
    end
    return "none"
end

# Returns the declared type of the specified identifier
function type_of(table::SymbolTable, name::String)
    if haskey(table.subroutine_scope, name)
        return table.subroutine_scope[name].type
    elseif haskey(table.class_scope, name)
        return table.class_scope[name].type
    end
    return ""
end

# Returns the running index assigned to the identifier
function index_of(table::SymbolTable, name::String)
    if haskey(table.subroutine_scope, name)
        return table.subroutine_scope[name].index
    elseif haskey(table.class_scope, name)
        return table.class_scope[name].index
    end
    return -1
end

# Converts a symbol kind into its corresponding VM memory segment
function kind_to_segment(kind::String)
    if kind == "static"
        return "static"
    elseif kind == "field"
        return "this"
    elseif kind == "argument"
        return "argument"
    elseif kind == "var"
        return "local"
    end
    return ""
end