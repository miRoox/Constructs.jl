
"""
    ConstructError <: Exception

Abstract error type for constructs.
"""
abstract type ConstructError <: Exception end

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
