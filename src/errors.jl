
"""
    ConstructError <: Exception

Abstract error type for constructs.
"""
abstract type ConstructError <: Exception end

function Base.showerror(io::IO, err::ConstructError)
    print(io, "ConstructError: ")
    print(io, typeof(err), ": ")
    print(io, message(err))
end

message(err::ConstructError) = getproperty(err, :msg)

"""
    ValidationOk

Placeholder type if there is no validatiion error.
"""
struct ValidationOk end

"""
    ValidationOK

Placeholder if there is no validatiion error.
"""
const ValidationOK = ValidationOk()

"""
    ValidationError(msg)

Error thrown when the validatiion failed.
"""
struct ValidationError <: ConstructError
    msg::String
end

const default_max_iter = UInt(0xffff)

"""
    ExceedMaxIterations(msg, [max_iter])

Error thrown when exceed the max iterations.
"""
struct ExceedMaxIterations <: ConstructError
    msg::String
    max_iter::UInt

    ExceedMaxIterations(msg::String, max_iter::UInt = default_max_iter) = new(msg, max_iter)
end

"""
    PaddedError(msg)

Error thrown when the encoded string or bytes takes more bytes than padding allows, or the pad value is improper.
"""
struct PaddedError <: ConstructError
    msg::String
end
