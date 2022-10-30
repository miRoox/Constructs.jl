struct RaiseError{E<:Exception} <: Construct{Union{}}
    err::E
end

"""
    RaiseError(error::Exception) -> Construct{Union{}}
    RaiseError(message::String) -> Construct{Union{}}

Raise specific `error` or `ErrorException(message)` when serializing or deserializing any data.
"""
RaiseError(msg::AbstractString) = RaiseError(ErrorException(msg))

# this method is not consistent with the Construct interface,
# but it's acceptable because it never writes anything to the stream.
serialize(cons::RaiseError, ::IO, ::Any; contextkw...) = throw(cons.err)
serialize(cons::RaiseError, ::IO, ::UndefProperty; contextkw...) = throw(cons.err)
# serialize(cons::RaiseError, ::IO, ::Union{}; contextkw...) = throw(cons.err) # unreachable
deserialize(cons::RaiseError, ::IO; contextkw...) = throw(cons.err)
estimatesize(cons::RaiseError; contextkw...) = ExactSize(0)
