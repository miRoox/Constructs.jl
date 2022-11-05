var documenterSearchIndex = {"docs":
[{"location":"reference/#API-References","page":"References","title":"API References","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Pages = [\"reference.md\"]\nDepth = 3","category":"page"},{"location":"reference/","page":"References","title":"References","text":"Constructs","category":"page"},{"location":"reference/#Constructs","page":"References","title":"Constructs","text":"A declarative de-ser for binary data. Inspired by Construct.\n\n\n\n\n\n","category":"module"},{"location":"reference/#Basic-Interfaces","page":"References","title":"Basic Interfaces","text":"","category":"section"},{"location":"reference/#Construct","page":"References","title":"Construct","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Construct{T}\nConstruct(cons::Construct)\nserialize\nserialize(cons::Construct{T}, filename::AbstractString, obj; contextkw...) where {T}\nserialize(cons::Construct{T}, obj; contextkw...) where {T}\nserialize(cons::Construct{T}, s::IO, ::UndefProperty; contextkw...) where {T}\ndeserialize\ndeserialize(cons::Construct, filename::AbstractString; contextkw...)\ndeserialize(cons::Construct, bytes::AbstractVector{UInt8}; contextkw...)\nestimatesize","category":"page"},{"location":"reference/#Constructs.Construct","page":"References","title":"Constructs.Construct","text":"Construct{T}\n\nConstruct is used for serializing and deserializing objects.\n\nMethods\n\ndeserialize(cons::Construct{T}, s::IO; contextkw...)\nserialize(cons::Construct{T}, s::IO, obj::T; contextkw...)\nestimatesize(cons::Construct{T}; contextkw...) - optional\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.Construct-Tuple{Construct}","page":"References","title":"Constructs.Construct","text":"Construct(T) -> Construct{T}\n\nGet default construct for type T.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.serialize","page":"References","title":"Constructs.serialize","text":"serialize(cons::Construct, s::IO, obj; contextkw...)\nserialize(T, s::IO, obj; contextkw...)\nserialize(s::IO, obj; contextkw...)\n\nSerialize an object into a stream.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Constructs.serialize-Union{Tuple{T}, Tuple{Construct{T}, AbstractString, Any}} where T","page":"References","title":"Constructs.serialize","text":"serialize(cons::Construct, filename::AbstractString, obj; contextkw...)\nserialize(T, filename::AbstractString, obj; contextkw...)\nserialize(filename::AbstractString, obj; contextkw...)\n\nSerialize an object to the file.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.serialize-Union{Tuple{T}, Tuple{Construct{T}, Any}} where T","page":"References","title":"Constructs.serialize","text":"serialize(cons::Construct, obj; contextkw...) -> Vector{UInt8}\nserialize(T, obj; contextkw...) -> Vector{UInt8}\nserialize(obj; contextkw...) -> Vector{UInt8}\n\nSerialize an object in memory (a byte array).\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.serialize-Union{Tuple{T}, Tuple{Construct{T}, IO, UndefProperty}} where T","page":"References","title":"Constructs.serialize","text":"serialize(cons::Construct{T}, s::IO, ::UndefProperty; contextkw...) -> T\n\nSerialize an insufficient object into a stream.\n\nNote\n\nThis method is usually called for anonymous fields in @construct.\n\nBy default, only singleton types support this because they don't need to write anything.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.deserialize","page":"References","title":"Constructs.deserialize","text":"deserialize(cons::Construct{T}, s::IO; contextkw...) -> T\ndeserialize(T, s::IO; contextkw...) -> T\n\nDeserialize a stream to an object.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Constructs.deserialize-Tuple{Construct, AbstractString}","page":"References","title":"Constructs.deserialize","text":"deserialize(cons::Construct{T}, filename::AbstractString; contextkw...) -> T\ndeserialize(T, filename::AbstractString; contextkw...) -> T\n\nDeserialize a file to an object.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.deserialize-Tuple{Construct, AbstractVector{UInt8}}","page":"References","title":"Constructs.deserialize","text":"deserialize(cons::Construct{T}, bytes::AbstractVector{UInt8}; contextkw...) -> T\ndeserialize(T, bytes::AbstractVector{UInt8}; contextkw...) -> T\n\nDeserialize a byte array to an object.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.estimatesize","page":"References","title":"Constructs.estimatesize","text":"estimatesize(cons::Construct; contextkw...) -> ConstructSize\nestimatesize(T; contextkw...) -> ConstructSize\n\nEstimate the size of the type.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Wrapper","page":"References","title":"Wrapper","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Wrapper{TSub, T}\nsubcon","category":"page"},{"location":"reference/#Constructs.Wrapper","page":"References","title":"Constructs.Wrapper","text":"Wrapper{TSub, T} <: Construct{T}\n\nAbstract wrapper for TSub.\n\nMethods\n\nsubcon(wrapper::Wrapper{TSub, T})\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.subcon","page":"References","title":"Constructs.subcon","text":"subcon(wrapper::Wrapper{TSub, T}) -> Construct{TSub}\n\nGet sub-construct of wrapper.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Adapter","page":"References","title":"Adapter","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Adapter{TSub, T}\nSymmetricAdapter{T}\nSymmetricAdapter(subcon::Union{Type, Construct}, encode::Function)\nencode\ndecode","category":"page"},{"location":"reference/#Constructs.Adapter","page":"References","title":"Constructs.Adapter","text":"Adapter{TSub, T} <: Wrapper{TSub, T}\n\nAbstract adapter type.\n\nMethods\n\nsubcon(adapter::Adapter{TSub, T})\nencode(adapter::Adapter{TSub, T}, obj::T; contextkw...)\ndecode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...)\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.SymmetricAdapter","page":"References","title":"Constructs.SymmetricAdapter","text":"SymmetricAdapter{T} <: Adapter{T, T}\n\nAbstract adapter type. encode both for serializing and deserializing.\n\nMethods\n\nsubcon(adapter::SymmetricAdapter{T})\nencode(adapter::SymmetricAdapter{T}, obj::T; contextkw...)\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.SymmetricAdapter-Tuple{Union{Construct, Type}, Function}","page":"References","title":"Constructs.SymmetricAdapter","text":"Adapter(T|subcon, encode) -> SymmetricAdapter{T}\nSymmetricAdapter(T|subcon, encode) -> SymmetricAdapter{T}\n\nCreate a symmetric adapter based on the encode function.\n\nArguments\n\nsubcon::Construct{T}: the underlying construct.\nencode: the encoding function. the function should have signature like (::T; contextkw...)->T and satisfies involution (encode(encode(x)) == x).\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.encode","page":"References","title":"Constructs.encode","text":"encode(adapter::Adapter{TSub, T}, obj::T; contextkw...) -> TSub\n\nEncode the input object when serializing.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Constructs.decode","page":"References","title":"Constructs.decode","text":"decode(adapter::Adapter{TSub, T}, obj::TSub; contextkw...) -> T\n\nDecode the output object when deserializing.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Validator","page":"References","title":"Validator","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Validator{T}\nValidator(subcon::Union{Type, Construct}, validate::Function)\nvalidate","category":"page"},{"location":"reference/#Constructs.Validator","page":"References","title":"Constructs.Validator","text":"Validator{T} <: SymmetricAdapter{T}\n\nAbstract validator type. Validates a condition on the encoded/decoded object..\n\nMethods\n\nsubcon(validator::Validator{T})\nvalidate(validator::Validator{T}, obj::T; contextkw...)\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.Validator-Tuple{Union{Construct, Type}, Function}","page":"References","title":"Constructs.Validator","text":"Validator(T|subcon, validate) -> Validator{T}\n\nCreate a validator based on the validate function.\n\nArguments\n\nsubcon::Construct{T}: the underlying construct.\nvalidate: the validate function. the function should have signature like (::T; contextkw...)->Bool.\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.validate","page":"References","title":"Constructs.validate","text":"validate(validator::Validator{T}, obj::T; contextkw...) -> Bool\n\nChecks whether the given obj is a valid value for the validator.\n\nShould return a Bool or throw a ValidationError.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Primitive-Constructs","page":"References","title":"Primitive Constructs","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"PrimitiveIO\nSingleton\nJuliaSerializer\nRaiseError","category":"page"},{"location":"reference/#Constructs.PrimitiveIO","page":"References","title":"Constructs.PrimitiveIO","text":"PrimitiveIO(T) -> Construct{T}\n\nDefines a primitive IO construct for type based on read and write.\n\nThis is the default construct for Bool, Char, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32 and Float64.\n\nExamples\n\njulia> serialize(PrimitiveIO(Complex{Bool}), im)\n2-element Vector{UInt8}:\n 0x00\n 0x01\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.Singleton","page":"References","title":"Constructs.Singleton","text":"Singleton(T) -> Construct{T}\nSingleton(instance::T) -> Construct{T}\n\nDefines an empty construct for singleton type.\n\nThis is the default constructor for Nothing and Missing.\n\nExamples\n\njulia> serialize(missing)\nUInt8[]\n\njulia> deserialize(Singleton(pi), UInt8[])\nπ = 3.1415926535897...\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.JuliaSerializer","page":"References","title":"Constructs.JuliaSerializer","text":"JuliaSerializer([T = Any]) -> Construct{T}\n\nCreate the standard Julia serializer.\n\nSee also: Serialization\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.RaiseError","page":"References","title":"Constructs.RaiseError","text":"RaiseError(error::Exception) -> Construct{Union{}}\nRaiseError(message::String) -> Construct{Union{}}\n\nRaise specific error or ErrorException(message) when serializing or deserializing any data.\n\n\n\n\n\n","category":"type"},{"location":"reference/#String","page":"References","title":"String","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"NullTerminatedString\nPaddedString\nPrefixedString","category":"page"},{"location":"reference/#Constructs.NullTerminatedString","page":"References","title":"Constructs.NullTerminatedString","text":"NullTerminatedString([T], [encoding]) -> Construct{T}\n\nString ending in a terminating null character.\n\nThis is the default construct for the subtypes of AbstractString.\n\nArguments\n\nT<:AbstractString: the underlying string type.\nencoding::Union{Encoding, String}: the string encoding.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.PaddedString","page":"References","title":"Constructs.PaddedString","text":"PaddedString([T], n, [encoding]) -> Construct{T}\n\nString padded to n bytes.\n\nArguments\n\nT<:AbstractString: the underlying string type.\nn::Integer: the size of the string in bytes.\nencoding::Union{Encoding, String}: the string encoding.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.PrefixedString","page":"References","title":"Constructs.PrefixedString","text":"PrefixedString([T], S|size, [encoding]) -> Construct{T}\n\nString with the size in the header.\n\nArguments\n\nT<:AbstractString: the underlying string type.\nS<:Integer: the typeof the string size.\nsize::Construct{S}: the construct of the string size (in bytes).\nencoding::Union{Encoding, String}: the string encoding.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Endianness-Adapters","page":"References","title":"Endianness Adapters","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"LittleEndian\nBigEndian","category":"page"},{"location":"reference/#Constructs.LittleEndian","page":"References","title":"Constructs.LittleEndian","text":"LittleEndian(T) -> Construct{T}\n\nDefines the little endian format T.\n\nExamples\n\njulia> deserialize(LittleEndian(UInt16), b\"\\x12\\x34\")\n0x3412\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.BigEndian","page":"References","title":"Constructs.BigEndian","text":"BigEndian(T) -> Construct{T}\n\nDefines the big endian format T.\n\nExamples\n\njulia> deserialize(BigEndian(UInt16), b\"\\x12\\x34\")\n0x1234\n\n\n\n\n\n","category":"type"},{"location":"reference/","page":"References","title":"References","text":"Modules = [Constructs]\nFilter = c -> c isa LittleEndian || c isa BigEndian","category":"page"},{"location":"reference/#Constructs.Float16be","page":"References","title":"Constructs.Float16be","text":"Float16be = BigEndian(Float16)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Float16le","page":"References","title":"Constructs.Float16le","text":"Float16le = LittleEndian(Float16)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Float32be","page":"References","title":"Constructs.Float32be","text":"Float32be = BigEndian(Float32)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Float32le","page":"References","title":"Constructs.Float32le","text":"Float32le = LittleEndian(Float32)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Float64be","page":"References","title":"Constructs.Float64be","text":"Float64be = BigEndian(Float64)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Float64le","page":"References","title":"Constructs.Float64le","text":"Float64le = LittleEndian(Float64)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int128be","page":"References","title":"Constructs.Int128be","text":"Int128be = BigEndian(Int128)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int128le","page":"References","title":"Constructs.Int128le","text":"Int128le = LittleEndian(Int128)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int16be","page":"References","title":"Constructs.Int16be","text":"Int16be = BigEndian(Int16)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int16le","page":"References","title":"Constructs.Int16le","text":"Int16le = LittleEndian(Int16)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int32be","page":"References","title":"Constructs.Int32be","text":"Int32be = BigEndian(Int32)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int32le","page":"References","title":"Constructs.Int32le","text":"Int32le = LittleEndian(Int32)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int64be","page":"References","title":"Constructs.Int64be","text":"Int64be = BigEndian(Int64)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Int64le","page":"References","title":"Constructs.Int64le","text":"Int64le = LittleEndian(Int64)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt128be","page":"References","title":"Constructs.UInt128be","text":"UInt128be = BigEndian(UInt128)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt128le","page":"References","title":"Constructs.UInt128le","text":"UInt128le = LittleEndian(UInt128)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt16be","page":"References","title":"Constructs.UInt16be","text":"UInt16be = BigEndian(UInt16)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt16le","page":"References","title":"Constructs.UInt16le","text":"UInt16le = LittleEndian(UInt16)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt32be","page":"References","title":"Constructs.UInt32be","text":"UInt32be = BigEndian(UInt32)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt32le","page":"References","title":"Constructs.UInt32le","text":"UInt32le = LittleEndian(UInt32)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt64be","page":"References","title":"Constructs.UInt64be","text":"UInt64be = BigEndian(UInt64)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.UInt64le","page":"References","title":"Constructs.UInt64le","text":"UInt64le = LittleEndian(UInt64)\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Enums","page":"References","title":"Enums","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"IntEnum(subcon::Union{Type, Construct}, ::Type{E}) where {E<:Base.Enum}\nIntEnum{Ex}(subcon::TSubCon, ::Type{E}) where {Ex, T<:Integer, TSubCon<:Construct{T}, E<:Base.Enum}\nEnumNonExhaustive\nEnumExhaustive","category":"page"},{"location":"reference/#Constructs.IntEnum-Union{Tuple{E}, Tuple{Union{Construct, Type}, Type{E}}} where E<:Enum","page":"References","title":"Constructs.IntEnum","text":"IntEnum([T|subcon], E) -> Construct{E}\n\nDefines the (exhaustive) enumeration based on integer type T.\n\nThis is the default constructor for Base.Enum{T}.\n\nArguments\n\nT<:Integer: the underly integer type, default is the base type of E.\nsubcon::Construct{T}: the underly integer construct.\nE<:Base.Enum: the enum type.\n\nExamples\n\njulia> @enum Fruit::UInt8 apple=1 banana=2 orange=3\n\njulia> deserialize(IntEnum(Fruit), b\"\\x02\")\nbanana::Fruit = 0x02\n\njulia> deserialize(IntEnum(Fruit), b\"\\x04\")\nERROR: ArgumentError: invalid value for Enum Fruit: 4\n[...]\n\njulia> serialize(IntEnum(UInt16le, Fruit), orange)\n2-element Vector{UInt8}:\n 0x03\n 0x00\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.IntEnum-Union{Tuple{E}, Tuple{TSubCon}, Tuple{T}, Tuple{Ex}, Tuple{TSubCon, Type{E}}} where {Ex, T<:Integer, TSubCon<:Construct{T}, E<:Enum}","page":"References","title":"Constructs.IntEnum","text":"IntEnum{EnumNonExhaustive}([T|subcon], E) -> Construct{E}\n\nDefines the non-exhaustive enumeration based on integer type T.\n\nArguments\n\nT<:Integer: the underly integer type, default is the base type of E.\nsubcon::Construct{T}: the underly integer construct.\nE<:Base.Enum: the enum type.\n\nExamples\n\njulia> @enum Fruit::UInt8 apple=1 banana=2 orange=3\n\njulia> deserialize(IntEnum{EnumNonExhaustive}(Fruit), b\"\\x04\")\n<invalid #4>::Fruit = 0x04\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.EnumNonExhaustive","page":"References","title":"Constructs.EnumNonExhaustive","text":"EnumNonExhaustive <: EnumExhaustibility\n\nIndicates the enumeration is non-exhaustive.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.EnumExhaustive","page":"References","title":"Constructs.EnumExhaustive","text":"EnumExhaustive <: EnumExhaustibility\n\nIndicates the enumeration is exhaustive.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Sequence","page":"References","title":"Sequence","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Sequence","category":"page"},{"location":"reference/#Constructs.Sequence","page":"References","title":"Constructs.Sequence","text":"Sequence(Ts|elements...) -> Construct{Tuple{Ts...}}\n\nDefines the sequence of construct data based on elements.\n\nThis is the default constructor for Tuple{Ts...}.\n\nExamples\n\njulia> serialize((true, 0x23))\n2-element Vector{UInt8}:\n 0x01\n 0x23\n\njulia> deserialize(Sequence(Bool, UInt8), b\"\\xab\\xcd\")\n(true, 0xcd)\n\nKnown problems\n\nIn Julia 1.6, if the number of Sequence elements is greater than 9, @construct cannot deduce the field type correctly.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Repeaters","page":"References","title":"Repeaters","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"SizedArray\nPrefixedArray\nGreedyVector","category":"page"},{"location":"reference/#Constructs.SizedArray","page":"References","title":"Constructs.SizedArray","text":"SizedArray([TA], T|element, size...) -> Construct{TA}\n\nDefines an array with specific size and element.\n\nArguments\n\nTA<:AbstractArray{T}: the target array type, the default is Array{T, N}.\nT: the type of elements.\nelement::Construct{T}: the construct of elements.\nsize: the size of the array.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.PrefixedArray","page":"References","title":"Constructs.PrefixedArray","text":"PrefixedArray([TA], S|size, T|element) -> Construct{TA}\n\nDefines an array with its size in the header.\n\nArguments\n\nTA<:AbstractArray{T, N}: the target array type, the default is Array{T, N}.\nS<:Union{Integer, NTuple{N, Integer}}: the type of the size in the header.\nT: the type of elements.\nsize::Construct{S}: the construct of size.\nelement::Construct{T}: the construct of elements.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Constructs.GreedyVector","page":"References","title":"Constructs.GreedyVector","text":"GreedyVector(T|element) -> Construct{Vector{T}}\n\nDefines an unknown-sized vector, which will deserialize elements as much as possible.\n\nArguments\n\nT: the type of elements.\nelement::Construct{T}: the construct of elements.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Conditional","page":"References","title":"Conditional","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Try","category":"page"},{"location":"reference/#Constructs.Try","page":"References","title":"Constructs.Try","text":"Try(T1|subcon1, T2|subcon2, ...) -> Construct{Union{T1, T2, ...}}\nTry{TU}(T1|subcon1, T2|subcon2, ...) -> Construct{TU}\n\nTry each subcon and use the first successful one.\n\nExamples\n\nAnother non-exhaustive enum:\n\njulia> @enum Fruit::UInt8 apple=1 banana=2 orange=3\n\njulia> deserialize(Try(Fruit, UInt8), b\"\\x02\")\nbanana::Fruit = 0x02\n\njulia> deserialize(Try(Fruit, UInt8), b\"\\x04\")\n0x04\n\n\n\n\n\n","category":"type"},{"location":"reference/#Padded","page":"References","title":"Padded","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Padded","category":"page"},{"location":"reference/#Constructs.Padded","page":"References","title":"Constructs.Padded","text":"Padded([T|subcon = Nothing], n) -> Construct{T}\n\nCreate n-bytes padded data from subcon.\n\nArguments\n\nsubcon::Construct{T}: the construct to be padded.\nn::Integer: the size in bytes after padded.\n\nExamples\n\njulia> deserialize(Padded(Int8, 2), b\"\\x01\\xfc\")\n1\n\njulia> serialize(Padded(Int8, 2), Int8(1))\n2-element Vector{UInt8}:\n 0x01\n 0x00\n\n\n\n\n\n","category":"type"},{"location":"reference/#Others","page":"References","title":"Others","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"Const\nOverwrite","category":"page"},{"location":"reference/#Constructs.Const","page":"References","title":"Constructs.Const","text":"Const([T|subcon], value::T) -> Construct{T}\n\nDefines a constant value, usually used for file headers.\n\nArguments\n\nsubcon::Construct{T}: the underlying construct.\nvalue::T: the expected value.\n\nExamples\n\njulia> serialize(Const(0x01), 0x01)\n1-element Vector{UInt8}:\n 0x01\n\njulia> deserialize(Const(0x01), b\"\\x01\")\n0x01\n\njulia> serialize(Const(0x01), 0x03)\nERROR: ValidationError: 3 mismatch the const value 1.\n[...]\n\njulia> deserialize(Const(0x01), b\"\\x02\")\nERROR: ValidationError: 2 mismatch the const value 1.\n[...]\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.Overwrite","page":"References","title":"Constructs.Overwrite","text":"Overwrite(T, value::T) -> Construct{T}\nOverwrite(T, getter) -> Construct{T}\nOverwrite(subcon::Construct{T}, value::T) -> Construct{T}\nOverwrite(subcon::Construct{T}, getter) -> Construct{T}\n\nOverwrite the value when serializing from getter/value. Deserialization simply passes down.\n\nArguments\n\nsubcon::Construct{T}: the underlying construct.\nvalue::T: the value to overwrite when serializing.\ngetter: the function to overwrite when serializing. the function should have signature like (::T; contextkw...) and satisfies idempotence (getter(getter(x)) == getter(x)).\n\nExamples\n\njulia> serialize(Overwrite(UInt8, 0x01), 2)\n1-element Vector{UInt8}:\n 0x01\n\njulia> serialize(Overwrite(Int8, abs), -2)\n1-element Vector{UInt8}:\n 0x02\n\njulia> deserialize(Overwrite(UInt8, 0x01), b\"\\x05\")\n0x05\n\n\n\n\n\n","category":"type"},{"location":"reference/#@construct-Macro","page":"References","title":"@construct Macro","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"@construct\nthis\nContainer{T}\nContainer(obj::T) where {T}\nUndefProperty\nPropertyPath","category":"page"},{"location":"reference/#Constructs.@construct","page":"References","title":"Constructs.@construct","text":"@construct [ConstructName] structdefinition\n\nGenerate a Construct subtype with ConstructName for the given struct.\n\nExamples\n\njulia> @construct struct Bitmap\n           ::Const(b\"BMP\")\n           width::UInt16le\n           height::UInt16le\n           pixel::SizedArray(UInt8, this.height, this.width)\n       end\n\njulia> deserialize(Bitmap, b\"BMP\\x03\\x00\\x02\\x00\\x01\\x02\\x03\\x04\\x05\\x06\")\nBitmap(0x0003, 0x0002, UInt8[0x01 0x03 0x05; 0x02 0x04 0x06])\n\njulia> serialize(Bitmap(2, 3, UInt8[1 2; 4 6; 8 9]))\n13-element Vector{UInt8}:\n 0x42\n 0x4d\n 0x50\n 0x02\n 0x00\n 0x03\n 0x00\n 0x01\n 0x04\n 0x08\n 0x02\n 0x06\n 0x09\n\njulia> estimatesize(Bitmap)\nUnboundedSize(0x0000000000000007)\n\n\n\n\n\n","category":"macro"},{"location":"reference/#Constructs.this","page":"References","title":"Constructs.this","text":"this\n\nPlaceholder to access properties of the current object in @construct context.\n\n\n\n\n\n","category":"constant"},{"location":"reference/#Constructs.Container","page":"References","title":"Constructs.Container","text":"Container{T}\n\nIntermediate container for a struct object when serializing/deserializing it.\n\nContainer{T}()\n\nCreate an uninitialized container for T.\n\nExamples\n\njulia> Container{Complex{Int64}}()\nContainer{Complex{Int64}}:\n  re: #undef\n  im: #undef\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.Container-Tuple{T} where T","page":"References","title":"Constructs.Container","text":"Container(object)\n\nCreate a container from object.\n\nExamples\n\njulia> Container(3+4im)\nContainer{Complex{Int64}}:\n  re: Int64 = 3\n  im: Int64 = 4\n\n\n\n\n\n","category":"method"},{"location":"reference/#Constructs.UndefProperty","page":"References","title":"Constructs.UndefProperty","text":"UndefProperty\n\nPlaceholder for undefined properties in Container.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.PropertyPath","page":"References","title":"Constructs.PropertyPath","text":"PropertyPath(segments)\n\nRepresents a property path.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Construct-Sizes","page":"References","title":"Construct Sizes","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"ConstructSize\nExactSize\nRangedSize\nUnboundedSize\nUnboundedUpper","category":"page"},{"location":"reference/#Constructs.ConstructSize","page":"References","title":"Constructs.ConstructSize","text":"ConstructSize\n\nAbstract super type of construct size.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.ExactSize","page":"References","title":"Constructs.ExactSize","text":"ExactSize(value)\n\nExact construct size (upper bound and lower bound are same).\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.RangedSize","page":"References","title":"Constructs.RangedSize","text":"RangedSize(lower, upper)\n\nRanged construct size.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.UnboundedSize","page":"References","title":"Constructs.UnboundedSize","text":"UnboundedSize(lower)\n\nUnbounded ranged size.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.UnboundedUpper","page":"References","title":"Constructs.UnboundedUpper","text":"UnboundedUpper\n\nUnsigned infinity.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Errors","page":"References","title":"Errors","text":"","category":"section"},{"location":"reference/","page":"References","title":"References","text":"AbstractConstructError\nValidationError\nExceedMaxIterations\nPaddedError","category":"page"},{"location":"reference/#Constructs.AbstractConstructError","page":"References","title":"Constructs.AbstractConstructError","text":"AbstractConstructError <: Exception\n\nAbstract error type for constructs.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.ValidationError","page":"References","title":"Constructs.ValidationError","text":"ValidationError(msg)\n\nError thrown when the validatiion failed.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.ExceedMaxIterations","page":"References","title":"Constructs.ExceedMaxIterations","text":"ExceedMaxIterations(msg, [max_iter])\n\nError thrown when exceed the max iterations.\n\n\n\n\n\n","category":"type"},{"location":"reference/#Constructs.PaddedError","page":"References","title":"Constructs.PaddedError","text":"PaddedError(msg)\n\nError thrown when the encoded string or bytes takes more bytes than padding allows, or the pad value is improper.\n\n\n\n\n\n","category":"type"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = Constructs","category":"page"},{"location":"#Constructs","page":"Home","title":"Constructs","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A declarative deserialization-serialization for binary data. Inspired by Construct.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Constructs can be installed with the Julia package manager.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"Constructs\")","category":"page"},{"location":"#Basic-Usage","page":"Home","title":"Basic Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"@construct defines the struct type and the corresponding deserialize/serialize methods. The following Bitmap has a BMP header, width and height in UInt16 little-endian format, and pixel which is a 2-dimensional byte array with the specified width and height.","category":"page"},{"location":"","page":"Home","title":"Home","text":"julia> using Constructs\n\njulia> @construct struct Bitmap\n           ::Const(b\"BMP\")\n           width::UInt16le\n           height::UInt16le\n           pixel::SizedArray(UInt8, this.height, this.width) # Julia arrays are column major\n       end\n\njulia> deserialize(Bitmap, b\"BMP\\x02\\x00\\x03\\x00\\x01\\x02\\x03\\x04\\x05\\x06\")\nBitmap(0x0002, 0x0003, UInt8[0x01 0x04; 0x02 0x05; 0x03 0x06])\n\njulia> serialize(Bitmap(3, 2, UInt8[1 2 3; 7 8 9]))\n13-element Vector{UInt8}:\n 0x42\n 0x4d\n 0x50\n 0x03\n 0x00\n 0x02\n 0x00\n 0x01\n 0x07\n 0x02\n 0x08\n 0x03\n 0x09","category":"page"}]
}
