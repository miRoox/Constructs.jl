var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Constructs","category":"page"},{"location":"#Constructs","page":"Home","title":"Constructs","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Constructs.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Constructs]","category":"page"},{"location":"#Constructs.Constructs","page":"Home","title":"Constructs.Constructs","text":"A declarative de-ser for binary data. Inspired by Construct.\n\n\n\n\n\n","category":"module"},{"location":"#Constructs.ValidationOK","page":"Home","title":"Constructs.ValidationOK","text":"ValidationOK\n\nPlaceholder if there is no validatiion error.\n\n\n\n\n\n","category":"constant"},{"location":"#Constructs.this","page":"Home","title":"Constructs.this","text":"this\n\nPlaceholder to access properties of the current object in @construct context.\n\n\n\n\n\n","category":"constant"},{"location":"#Constructs.Adapter","page":"Home","title":"Constructs.Adapter","text":"Adapter{TSub, T} <: Wrapper{TSub, T}\n\nAbstract adapter type.\n\nMethods\n\nsubcon(adapter::Adapter{TSub, T})::Construct{TSub}\nencode(adapter::Adapter{TSub, T}, obj::T; contextkw...)\ndecode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...)\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.BaseArray","page":"Home","title":"Constructs.BaseArray","text":"BaseArray{T, N, TA<:AbstractArray{T,N}} <: Wrapper{T, TA}\n\nAbstract base type for Array wrapper.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.BigEndian","page":"Home","title":"Constructs.BigEndian","text":"BigEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}\n\nBig endian data adapter for serializing and deserializing.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Const","page":"Home","title":"Constructs.Const","text":"Const{T, TSubCon<:Construct{T}, VT} <: Validator{T}\n\nField enforcing a constant.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Construct","page":"Home","title":"Constructs.Construct","text":"Construct{T}\n\nConstruct is used for serializing and deserializing objects.\n\nMethods\n\ndeserialize(cons::Construct{T}, s::IO; contextkw...)::T\nserialize(cons::Construct{T}, s::IO, obj::T; contextkw...)\nestimatesize(cons::Construct{T}; contextkw...) - optional\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Construct-Tuple{Construct}","page":"Home","title":"Constructs.Construct","text":"Construct(type)\n\nGet default construct for type.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.ConstructError","page":"Home","title":"Constructs.ConstructError","text":"ConstructError <: Exception\n\nAbstract error type for constructs.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.ConstructSize","page":"Home","title":"Constructs.ConstructSize","text":"ConstructSize\n\nAbstract super type of construct size.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Container","page":"Home","title":"Constructs.Container","text":"Container{T}\n\nIntermediate container for a struct object when serializing/deserializing it.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.ExactSize","page":"Home","title":"Constructs.ExactSize","text":"ExactSize\n\nExact construct size (upper bound and lower bound are same).\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.ExceedMaxIterations","page":"Home","title":"Constructs.ExceedMaxIterations","text":"ExceedMaxIterations(msg, [max_iter])\n\nError thrown when exceed the max iterations.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.GreedyVector","page":"Home","title":"Constructs.GreedyVector","text":"GreedyVector{T, TSubCon<:Construct{T}} <: BaseArray{T, 1, Vector{T}}\n\nHomogenous array of elements for unknown count of elements by parsing until end of stream.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.IntEnum","page":"Home","title":"Constructs.IntEnum","text":"IntEnum{T, TSubCon<:Construct{T}, E<:Base.Enum} <: Adapter{T, E}\n\nInteger-based enum adapter for serializing and deserializing.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.JuliaSerializer","page":"Home","title":"Constructs.JuliaSerializer","text":"JuliaSerializer <: Construct{Any}\n\nStandard Julia serialization.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.LittleEndian","page":"Home","title":"Constructs.LittleEndian","text":"LittleEndian{T, TSubCon<:Construct{T}} <: Adapter{T, T}\n\nLittle endian data adapter for serializing and deserializing.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Padded","page":"Home","title":"Constructs.Padded","text":"Padded{T, TSubCon<:Construct{T}} <: Wrapper{T, T}\n\nRepresents Padded data.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.PaddedError","page":"Home","title":"Constructs.PaddedError","text":"PaddedError(msg)\n\nError thrown when the encoded string or bytes takes more bytes than padding allows, or the pad value is improper.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.PrimitiveIO","page":"Home","title":"Constructs.PrimitiveIO","text":"PrimitiveIO{T} <: Construct{T}\n\nConstruct based on primitive read/write.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.RangedSize","page":"Home","title":"Constructs.RangedSize","text":"RangedSize\n\nRanged construct size.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Sequence","page":"Home","title":"Constructs.Sequence","text":"Sequence{Tuple{Ts...}} <: Construct{Tuple{Ts...}}\n\nA sequence of construct data.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Singleton","page":"Home","title":"Constructs.Singleton","text":"Singleton{T} <: Construct{T}\n\nSingleton type empty construct.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.SizedArray","page":"Home","title":"Constructs.SizedArray","text":"SizedArray{T, N, TA<:AbstractArray{T,N}, TSubCon<:Construct{T}} <: BaseArray{T, N, TA}\n\nHomogenous array of elements.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.SymmetricAdapter","page":"Home","title":"Constructs.SymmetricAdapter","text":"SymmetricAdapter{T} <: Adapter{T, T}\n\nAbstract adapter type. encode both for serializing and deserializing.\n\nMethods\n\nsubcon(adapter::SymmetricAdapter{T})::Construct{T}\nencode(adapter::SymmetricAdapter{T}, obj::T; contextkw...)\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Try","page":"Home","title":"Constructs.Try","text":"Try{TU} <: Construct{TU}\n\nAttempts to serialize/deserialize each of the subconstructs.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.UnboundedSize","page":"Home","title":"Constructs.UnboundedSize","text":"UnboundedSize\n\nUnbounded ranged size.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.UnboundedUpper","page":"Home","title":"Constructs.UnboundedUpper","text":"UnboundedUpper\n\nUnsigned infinity.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.ValidationError","page":"Home","title":"Constructs.ValidationError","text":"ValidationError(msg)\n\nError thrown when the validatiion failed.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.ValidationOk","page":"Home","title":"Constructs.ValidationOk","text":"ValidationOk\n\nPlaceholder type if there is no validatiion error.\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Validator","page":"Home","title":"Constructs.Validator","text":"Validator{T} <: SymmetricAdapter{T}\n\nAbstract validator type. Validates a condition on the encoded/decoded object..\n\nMethods\n\nsubcon(validator::Validator{T})::Construct{T}\nvalidate(validator::Validator{T}, obj::T; contextkw...)::Union{ValidationOk, ValidationError}\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.Wrapper","page":"Home","title":"Constructs.Wrapper","text":"Wrapper{TSub, T} <: Construct{T}\n\nBase type of wrapper of TSub.\n\nMethods\n\nsubcon(wrapper::Wrapper{TSub, T})::Construct{TSub}\n\n\n\n\n\n","category":"type"},{"location":"#Constructs.decode","page":"Home","title":"Constructs.decode","text":"decode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...) where {TSub, T}\n\n\n\n\n\n","category":"function"},{"location":"#Constructs.deserialize","page":"Home","title":"Constructs.deserialize","text":"deserialize(cons::Construct, s::IO; contextkw...)\n\nDeserialize a stream to an object.\n\n\n\n\n\n","category":"function"},{"location":"#Constructs.deserialize-Tuple{Construct, AbstractString}","page":"Home","title":"Constructs.deserialize","text":"deserialize(cons::Construct, filename::AbstractString; contextkw...)\n\nDeserialize a file to an object.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.deserialize-Tuple{Construct, AbstractVector{UInt8}}","page":"Home","title":"Constructs.deserialize","text":"deserialize(cons::Construct, bytes::AbstractVector{UInt8}; contextkw...)\n\nDeserialize a byte array to an object.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.deserialize-Tuple{Type, AbstractString}","page":"Home","title":"Constructs.deserialize","text":"deserialize(T, filename::AbstractString; contextkw...)\n\nDeserialize a file to an object.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.deserialize-Tuple{Type, AbstractVector{UInt8}}","page":"Home","title":"Constructs.deserialize","text":"deserialize(T, bytes::AbstractVector{UInt8}; contextkw...)\n\nDeserialize a byte array to an object.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.deserialize-Tuple{Type, IO}","page":"Home","title":"Constructs.deserialize","text":"deserialize(T, s::IO; contextkw...)\n\nDeserialize a stream to an object.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.encode","page":"Home","title":"Constructs.encode","text":"encode(adapter::Adapter{TSub, T}, obj::T; contextkw...) where {TSub, T}\n\n\n\n\n\n","category":"function"},{"location":"#Constructs.estimatesize-Tuple{Construct}","page":"Home","title":"Constructs.estimatesize","text":"estimatesize(cons::Construct; contextkw...)\n\nEstimate the size of the type.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.estimatesize-Tuple{Type}","page":"Home","title":"Constructs.estimatesize","text":"estimatesize(T; contextkw...)\n\nEstimate the size of the type.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.serialize","page":"Home","title":"Constructs.serialize","text":"serialize(cons::Construct, s::IO, obj; contextkw...)\n\nSerialize an object into a stream.\n\n\n\n\n\n","category":"function"},{"location":"#Constructs.serialize-Tuple{AbstractString, Any}","page":"Home","title":"Constructs.serialize","text":"serialize(filename::AbstractString, obj; contextkw...)\n\nSerialize an object to the file.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.serialize-Tuple{Any}","page":"Home","title":"Constructs.serialize","text":"serialize(obj; contextkw...)\n\nSerialize an object in memory (a byte array).\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.serialize-Tuple{IO, Any}","page":"Home","title":"Constructs.serialize","text":"serialize(obj, s::IO; contextkw...)\n\nSerialize an object into a stream.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.serialize-Union{Tuple{T}, Tuple{Construct{T}, AbstractString, T}} where T","page":"Home","title":"Constructs.serialize","text":"serialize(cons::Construct, filename::AbstractString, obj; contextkw...)\n\nSerialize an object to the file.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.serialize-Union{Tuple{T}, Tuple{Construct{T}, T}} where T","page":"Home","title":"Constructs.serialize","text":"serialize(cons::Construct, obj; contextkw...)\n\nSerialize an object in memory (a byte array).\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.subcon-Tuple{Wrapper}","page":"Home","title":"Constructs.subcon","text":"subcon(wrapper::Wrapper{TSub, T})::Construct{TSub}\n\nGet sub-construct of wrapper.\n\n\n\n\n\n","category":"method"},{"location":"#Constructs.validate","page":"Home","title":"Constructs.validate","text":"validate(validator::Validator{T}, obj::T; contextkw...)::Union{ValidationOk, ValidationError}\n\n\n\n\n\n","category":"function"},{"location":"#Constructs.@construct-Tuple{Expr}","page":"Home","title":"Constructs.@construct","text":"@construct [ConstructName] structdefinition\n\nGenerate a Construct{T} subtype with ConstructName for the given struct.\n\n\n\n\n\n","category":"macro"}]
}
