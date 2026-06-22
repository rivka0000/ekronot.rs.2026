# ====================================================================
# File: VMWriter.jl
# Role: Writes VM commands into the output .vm file.
# ====================================================================

# Represents the VM output file used for writing commands
mutable struct VMWriter
    output_file::IOStream
end

# Creates a new VM writer and opens the target output file
function create_vm_writer(output_path::String)
    out = open(output_path, "w")
    return VMWriter(out)
end

# Closes the VM output file when compilation is complete
function close_vm_writer!(writer::VMWriter)
    close(writer.output_file)
end

# Writes a VM push command to push a value from a segment onto the stack
function write_push!(writer::VMWriter, segment::String, index::Int)
    write(writer.output_file, "push $segment $index\n")
end

# Writes a VM pop command to store the top stack value into a segment
function write_pop!(writer::VMWriter, segment::String, index::Int)
    write(writer.output_file, "pop $segment $index\n")
end

# Writes a VM arithmetic or logical command
function write_arithmetic!(writer::VMWriter, command::String)
    write(writer.output_file, "$command\n")
end

# Writes a VM label declaration
function write_label!(writer::VMWriter, label::String)
    write(writer.output_file, "label $label\n")
end

# Writes an unconditional VM goto command
function write_goto!(writer::VMWriter, label::String)
    write(writer.output_file, "goto $label\n")
end

# Writes a conditional VM jump command
function write_if!(writer::VMWriter, label::String)
    write(writer.output_file, "if-goto $label\n")
end

# Writes a VM function call command with the specified number of arguments
function write_call!(writer::VMWriter, name::String, n_args::Int)
    write(writer.output_file, "call $name $n_args\n")
end

# Writes a VM function declaration command
function write_function!(writer::VMWriter, name::String, n_locals::Int)
    write(writer.output_file, "function $name $n_locals\n")
end

# Writes a VM return command to end the current function
function write_return!(writer::VMWriter)
    write(writer.output_file, "return\n")
end