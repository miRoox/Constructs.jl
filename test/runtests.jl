using Constructs
using MacroTools
using Test

@enum Fruit::Int8 begin
    apple
    banna
    orange
end

@testset "Constructs.jl" begin
    @testset "context" begin
        @test PropertyPath() == PropertyPath([])
        @test repr(PropertyPath()) == "(this)"
        @test repr(PropertyPath([:value])) == "(this) -> :value"
        @test repr(PropertyPath([:array, 2])) == "(this) -> :array -> 2"
        @testset "internal" begin
            @test Constructs.with_property((;), :value) == (; Constructs.pathkw => PropertyPath([:value]))
            @test Constructs.with_property((; a=1), :value) == (; a=1, Constructs.pathkw => PropertyPath([:value]))
            @test Constructs.with_property((; Constructs.pathkw => PropertyPath([:data])), :value) == (; Constructs.pathkw => PropertyPath([:data, :value]))
        end
    end
    @testset "errors" begin
        @test sprint(showerror, ValidationError("Invalid data")) == "ValidationError: Invalid data"
    end
    @testset "size" begin
        @testset "UnboundedUpper" begin
            @test 1 + UnboundedUpper() == UnboundedUpper()
            @test UnboundedUpper() + typemax(UInt64) == UnboundedUpper()
            @test UnboundedUpper() + UnboundedUpper() == UnboundedUpper()
            @test 0x10 * UnboundedUpper() == UnboundedUpper()
            @test UnboundedUpper() * typemax(UInt64) == UnboundedUpper()
            @test 0x0 * UnboundedUpper() == 0x0
            @test UnboundedUpper() * UnboundedUpper() == UnboundedUpper()
            @test max(1, UnboundedUpper()) == UnboundedUpper()
            @test max(UnboundedUpper(), typemax(UInt64)) == UnboundedUpper()
            @test max(UnboundedUpper(), UnboundedUpper()) == UnboundedUpper()
            @test min(1, UnboundedUpper()) == 1
            @test min(UnboundedUpper(), typemax(UInt64)) == typemax(UInt64)
            @test min(UnboundedUpper(), UnboundedUpper()) == UnboundedUpper()
            @test repr(UnboundedUpper()) == "+∞"
        end
        @testset "ConstructSize" begin
            @test ConstructSize(1, 1) == ExactSize(1)
            @test convert(Int, ExactSize(2)) == 2
            @test ConstructSize(1, 2) == RangedSize(1, 2)
            @test_throws ArgumentError ConstructSize(2, 1)
            @test_throws ArgumentError RangedSize(1, 1)
            @test RangedSize(1, 2) != 1
            @test UnboundedSize(typemax(UInt64)) != typemax(UInt64)
            @test ConstructSize(3, UnboundedUpper()) == UnboundedSize(3)
            @test ConstructSize(1) + ConstructSize(2) == ConstructSize(3)
            @test 1 + ConstructSize(2) + 3 == 6
            @test 3 + ConstructSize(1, 2) == ConstructSize(4, 5)
            @test UnboundedSize(1) + 2 == UnboundedSize(3)
            @test ConstructSize(2) * ConstructSize(3) == ConstructSize(6)
            @test 2 * ConstructSize(3) * 5 == 30
            @test 3 * ConstructSize(2, 4) == ConstructSize(6, 12)
            @test 0 * ConstructSize(2, 4) == 0
            @test UnboundedSize(2) * 3 == UnboundedSize(6)
            @test UnboundedSize(2) * 0 == 0
            @test union(ConstructSize(2), 3) == ConstructSize(2, 3)
            @test union(2, ConstructSize(3), 5) == ConstructSize(2, 5)
            @test union(3, ConstructSize(2, 4)) == ConstructSize(2, 4)
            @test union(6, ConstructSize(2, 4)) == ConstructSize(2, 6)
            @test union(ConstructSize(1, 3), ConstructSize(2, 4)) == ConstructSize(1, 4)
            @test union(UnboundedSize(3), 6) == UnboundedSize(3)
            @test union(UnboundedSize(3), 1) == UnboundedSize(1)
            @test !(0 in RangedSize(1, 3))
            @test 1 in RangedSize(1, 3)
            @test 2 in RangedSize(1, 3)
            @test 3 in RangedSize(1, 3)
            @test !(4 in RangedSize(1, 3))
            @test !(0 in ExactSize(1))
            @test 1 in ExactSize(1)
            @test !(2 in ExactSize(1))
            @test 1 in UnboundedSize(1)
            @test !(0 in UnboundedSize(1))
            @test typemax(UInt64) in UnboundedSize(1)
        end
    end
    @testset "container" begin
        @test repr(UndefProperty()) == "#undef"
        @test_throws ArgumentError Container(1)
        @test Container(im).im
        @test Container{Complex{Bool}}().im == UndefProperty()
        @test_throws ErrorException Container{Complex{Bool}}().i
        @test_throws ErrorException Container(im).im = false
        @test propertynames(Container(1//2)) == propertynames(1//2)
        @test propertynames(Container{Rational{Int}}()) == fieldnames(Rational{Int})
        @test repr(Container(3+4im)) == "Container{Complex{Int64}}(re=3, im=4)"
        @test repr(Container{Complex{Int64}}()) == "Container{Complex{Int64}}(re=#undef, im=#undef)"
        @test repr("text/plain", Container(3+4im)) == """
        Container{Complex{Int64}}:
          re: Int64 = 3
          im: Int64 = 4
        """
        @test repr("text/plain", Container{Complex{Int64}}()) == """
        Container{Complex{Int64}}:
          re: #undef
          im: #undef
        """
    end
    @testset "primitive io" begin
        @testset "primitive type $type" for type in (Bool, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64)
            @test estimatesize(type) == sizeof(type)
            @test deserialize(type, zeros(UInt8, sizeof(type))) == zero(type)
            @test serialize(zero(type)) == zeros(UInt8, sizeof(type))
        end
        @testset "char $c" for c in ['\x00', 'A', 'α', '啊', '🆗']
            codes = transcode(UInt8, [codepoint(c)])
            @test length(codes) in estimatesize(Char)
            @test deserialize(Char, codes) == c
            @test serialize(c) == codes
        end
    end
    @testset "singleton" begin
        @testset "auto singleton for $instance" for instance in (nothing, missing)
            type = typeof(instance)
            @test estimatesize(type) == 0
            @test deserialize(type, UInt8[]) === instance
            @test serialize(instance) == UInt8[]
            @test serialize(type, UndefProperty()) == UInt8[]
        end
        @testset "non-singleton type $type" for type in (Bool, Union{}, Char, DataType)
            @test_throws ArgumentError Singleton(type)
        end
    end
    @testset "RaiseError" begin
        @test estimatesize(RaiseError("Invalid data.")) == 0
        @test_throws ErrorException deserialize(RaiseError("Invalid data."), b"")
        @test_throws ValidationError deserialize(RaiseError(ValidationError("Invalid data.")), b"")
        @test_throws ErrorException serialize(RaiseError("Invalid data."), IOBuffer(), nothing)
        @test_throws ValidationError serialize(RaiseError(ValidationError("Invalid data.")), IOBuffer(), nothing)
        @test_throws ErrorException serialize(RaiseError("Invalid data."), IOBuffer(), UndefProperty())
        @test_throws ValidationError serialize(RaiseError(ValidationError("Invalid data.")), IOBuffer(), UndefProperty())
    end
    @testset "JuliaSerializer" begin
        @test estimatesize(JuliaSerializer()) == UnboundedSize(0)
        @testset "serde" for v in (nothing, 1, 22//7, π, 3//5+7im, [1 2.5 4im; 1+5.2im 1/3 Inf], "Lorem Ipsum")
            type = typeof(v)
            @test deserialize(JuliaSerializer(), serialize(JuliaSerializer(), v)) == v
            @test deserialize(JuliaSerializer(type), serialize(JuliaSerializer(type), v)) == v
        end
        @test_throws TypeError deserialize(JuliaSerializer(UInt), serialize(JuliaSerializer(Int), 1))
    end
    @testset "functional" begin
        @testset "Validator" begin
            @test_throws ArgumentError Validator(UInt8, () -> true)
            @test estimatesize(Validator(Int32, (v) -> v >= 0)) == 4
            @test serialize(Validator(Int8, (v) -> v >= 0), 0) == b"\x00"
            @test serialize(Validator(Int8, (v) -> v >= 0), 0; path=PropertyPath()) == b"\x00"
            @test_throws ValidationError serialize(Validator(Int8, (v) -> v >= 0), -1)
            @test serialize(Validator(Int8, (v; kw...) -> v >= get(kw, :min_value, 0)), 0) == b"\x00"
            @test_throws ValidationError serialize(Validator(Int8, (v; kw...) -> v >= get(kw, :min_value, 0)), -1)
            @test_throws ValidationError serialize(Validator(Int8, (v; kw...) -> v >= get(kw, :min_value, 0)), 0; min_value=1)
            @test deserialize(Validator(Int8, (v) -> v >= 0), b"\x00") == 0
            @test deserialize(Validator(Int8, (v) -> v >= 0), b"\x00"; path=PropertyPath()) == 0
            @test_throws ValidationError deserialize(Validator(Int8, (v) -> v >= 0), b"\xfe")
            @test deserialize(Validator(Int8, (v; kw...) -> v >= get(kw, :min_value, 0)), b"\x00") == 0
            @test_throws ValidationError deserialize(Validator(Int8, (v; kw...) -> v >= get(kw, :min_value, 0)), b"\xfe")
            @test_throws ValidationError deserialize(Validator(Int8, (v; kw...) -> v >= get(kw, :min_value, 0)), b"\x00"; min_value=1)
        end
        @testset "SymmetricAdapter" begin
            @test_throws ArgumentError Adapter(UInt8, () -> 0x01)
            @test SymmetricAdapter(UInt8, ~) == Adapter(UInt8, ~)
            @test estimatesize(Adapter(UInt8, ~)) == sizeof(UInt8)
            @test serialize(Adapter(UInt8, ~), 0xcd) == b"\x32"
            @test serialize(Adapter(UInt8, ~), 0xcd; path=PropertyPath()) == b"\x32"
            @test deserialize(Adapter(UInt8, ~), b"\xab") == 0x54
            @test deserialize(Adapter(UInt8, ~), b"\xab"; path=PropertyPath()) == 0x54
            @test serialize(Adapter(UInt8, (v; kw...) -> xor(v, get(kw, :mask, 0x00))), 0xcd) == b"\xcd"
            @test serialize(Adapter(UInt8, (v; kw...) -> xor(v, get(kw, :mask, 0x00))), 0xcd; mask=0xfe) == b"\x33"
            @test deserialize(Adapter(UInt8, (v; kw...) -> xor(v, get(kw, :mask, 0x00))), b"\xab") == 0xab
            @test deserialize(Adapter(UInt8, (v; kw...) -> xor(v, get(kw, :mask, 0x00))), b"\xab"; mask=0xef) == 0x44
        end
    end
    @testset "byte order" begin
        be = (
            (0x0102, b"\x01\x02"),
            (0x01020304, b"\x01\x02\x03\x04"),
            (0x0102030405060708, b"\x01\x02\x03\x04\x05\x06\x07\x08"),
            (Int32(-2140118960), b"\x80\x70\x60\x50"),
            (Inf16, b"\x7c\x00"),
            (Float32(-1.1), b"\xbf\x8c\xcc\xcd"),
            )
        @testset "little endian for $n" for (n, bs) in be
            type = typeof(n)
            lbs = reverse(bs)
            @test estimatesize(LittleEndian(type)) == sizeof(type)
            @test deserialize(LittleEndian(type), lbs) == n
            @test serialize(LittleEndian(type), n) == lbs
        end
        @testset "big endian for $n" for (n, bs) in be
            type = typeof(n)
            @test estimatesize(BigEndian(type)) == sizeof(type)
            @test deserialize(BigEndian(type), bs) == n
            @test serialize(BigEndian(type), n) == bs
        end
    end
    @testset "string" begin
        @testset "NullTerminatedString" begin
            @testset "deduce type" begin
                @test Constructs.deducetype(() -> NullTerminatedString()) <: Construct{String}
                @test Constructs.deducetype(() -> NullTerminatedString("UTF-16LE")) <: Construct{String}
                @test Constructs.deducetype(() -> NullTerminatedString(GenericString)) <: Construct{GenericString}
            end
            @testset "raw" begin
                @test Construct(String) == NullTerminatedString(String)
                @test estimatesize(NullTerminatedString()) == UnboundedSize(0)
                @test deserialize(NullTerminatedString(), b"啊aξ") == "啊aξ"
                @test deserialize(NullTerminatedString(), b"啊aξ\0ϕ一r") == "啊aξ"
                @test serialize(NullTerminatedString(), "啊aξ") == b"啊aξ\0"
                @test serialize(NullTerminatedString(), "啊aξ\0ϕ一r") == b"啊aξ\0ϕ一r\0"
            end
            @testset "UTF-8" begin
                @test deserialize(NullTerminatedString("UTF-8"), b"啊aξ") == "啊aξ"
                @test deserialize(NullTerminatedString("UTF-8"), b"啊aξ\0ϕ一r") == "啊aξ"
                @test serialize(NullTerminatedString("UTF-8"), "啊aξ") == b"啊aξ\0"
                @test serialize(NullTerminatedString("UTF-8"), "啊aξ\0ϕ一r") == b"啊aξ\0ϕ一r\0"
            end
            @testset "GB18030" begin
                @test deserialize(NullTerminatedString("GB18030"), b"\xb0\xa1a\xa6\xce") == "啊aξ"
                @test deserialize(NullTerminatedString("GB18030"), b"\xb0\xa1a\xa6\xce\0\x81\x30\xcd\x31\xd2\xbbr") == "啊aξ"
                @test serialize(NullTerminatedString("GB18030"), "啊aξ") == b"\xb0\xa1a\xa6\xce\0"
                @test serialize(NullTerminatedString("GB18030"), "啊aξ\0ϕ一r") == b"\xb0\xa1a\xa6\xce\0\x81\x30\xcd\x31\xd2\xbbr\0"
            end
            @testset "UTF-16LE" begin
                @test deserialize(NullTerminatedString("UTF-16LE"), b"\x4a\x55a\x00\xbe\x03") == "啊aξ"
                @test deserialize(NullTerminatedString("UTF-16LE"), b"\x4a\x55a\x00\xbe\x03\0\0\xd5\x03\x00\x4er\x00") == "啊aξ"
                @test serialize(NullTerminatedString("UTF-16LE"), "啊aξ") == b"\x4a\x55a\x00\xbe\x03\0\0"
                @test serialize(NullTerminatedString("UTF-16LE"), "啊aξ\0ϕ一r") == b"\x4a\x55a\x00\xbe\x03\0\0\xd5\x03\x00\x4er\x00\0\0"
            end
        end
        @testset "PaddedString" begin
            @testset "deduce type" begin
                @test Constructs.deducetype((n) -> PaddedString(n), Int) <: Construct{String}
                @test Constructs.deducetype((n) -> PaddedString(n, "UTF-16LE"), Int) <: Construct{String}
                @test Constructs.deducetype((n) -> PaddedString(GenericString, n), Int) <: Construct{GenericString}
            end
            @testset "raw" begin
                @test estimatesize(PaddedString(9)) == 9
                @test deserialize(PaddedString(4), b"啊aξ") == "啊a"
                @test deserialize(PaddedString(6), b"啊a\0\0") == "啊a"
                @test deserialize(PaddedString(6), b"啊\0a\0") == "啊\0a"
                @test_throws PaddedError serialize(PaddedString(4), "啊aξ")
                @test serialize(PaddedString(4), "啊a") == b"啊a"
                @test serialize(PaddedString(6), "啊a") == b"啊a\0\0"
                @test serialize(PaddedString(6), "啊\0a") == b"啊\0a\0"
            end
            @testset "UTF-8" begin
                @test estimatesize(PaddedString(9, "UTF-8")) == 9
                @test deserialize(PaddedString(4, "UTF-8"), b"啊aξ") == "啊a"
                @test deserialize(PaddedString(6, "UTF-8"), b"啊a\0\0") == "啊a"
                @test deserialize(PaddedString(6, "UTF-8"), b"啊\0a\0") == "啊\0a"
                @test_throws PaddedError serialize(PaddedString(4, "UTF-8"), "啊aξ")
                @test serialize(PaddedString(4, "UTF-8"), "啊a") == b"啊a"
                @test serialize(PaddedString(6, "UTF-8"), "啊a") == b"啊a\0\0"
                @test serialize(PaddedString(6, "UTF-8"), "啊\0a") == b"啊\0a\0"
            end
            @testset "GB18030" begin
                @test estimatesize(PaddedString(9, "GB18030")) == 9
                @test deserialize(PaddedString(3, "GB18030"), b"\xb0\xa1a\xa6\xce") == "啊a"
                @test deserialize(PaddedString(5, "GB18030"), b"\xb0\xa1a\0\0") == "啊a"
                @test deserialize(PaddedString(5, "GB18030"), b"\xb0\xa1\0a\0") == "啊\0a"
                @test_throws PaddedError serialize(PaddedString(4, "GB18030"), "啊aξ")
                @test serialize(PaddedString(3, "GB18030"), "啊a") == b"\xb0\xa1a"
                @test serialize(PaddedString(5, "GB18030"), "啊a") == b"\xb0\xa1a\0\0"
                @test serialize(PaddedString(5, "GB18030"), "啊\0a") == b"\xb0\xa1\0a\0"
            end
            @testset "UTF-16LE" begin
                @test estimatesize(PaddedString(9, "UTF-16LE")) == 9
                @test deserialize(PaddedString(4, "UTF-16LE"), b"\x4a\x55a\x00\xbe\x03") == "啊a"
                @test deserialize(PaddedString(6, "UTF-16LE"), b"\x4a\x55a\x00\0\0") == "啊a"
                @test deserialize(PaddedString(7, "UTF-16LE"), b"\x4a\x55\0\0a\x00\0") == "啊\0a"
                @test_throws PaddedError serialize(PaddedString(4, "UTF-16LE"), "啊aξ")
                @test serialize(PaddedString(4, "UTF-16LE"), "啊a") == b"\x4a\x55a\x00"
                @test serialize(PaddedString(5, "UTF-16LE"), "啊a") == b"\x4a\x55a\x00\0"
                @test serialize(PaddedString(6, "UTF-16LE"), "啊a") == b"\x4a\x55a\x00\0\0"
                @test serialize(PaddedString(7, "UTF-16LE"), "啊\0a") == b"\x4a\x55\0\0a\x00\0"
            end
        end
    end
    @testset "enum" begin
        @testset "auto type" begin
            @test estimatesize(Fruit) == sizeof(Int8)
            @test deserialize(Fruit, b"\x01") == banna
            @test_throws ArgumentError deserialize(Fruit, b"\x1f")
            @test serialize(orange) == b"\x02"
            @test serialize(reinterpret(Fruit, 0x1f)) == b"\x1f"
        end
        @testset "override base type" begin
            @test estimatesize(IntEnum(UInt8, Fruit)) == sizeof(UInt8)
            @test deserialize(IntEnum(UInt8, Fruit), b"\x01") == banna
            @test_throws ArgumentError deserialize(IntEnum(UInt8, Fruit), b"\x1f")
            @test serialize(IntEnum(UInt8, Fruit), orange) == b"\x02"
            @test serialize(IntEnum(UInt8, Fruit), reinterpret(Fruit, 0x1f)) == b"\x1f"
        end
        @testset "override base type construct" begin
            @test estimatesize(IntEnum(UInt16be, Fruit)) == sizeof(UInt16)
            @test deserialize(IntEnum(UInt16be, Fruit), b"\x00\x01") == banna
            @test_throws ArgumentError deserialize(IntEnum(UInt16be, Fruit), b"\x00\x1f")
            @test_throws InexactError deserialize(IntEnum(UInt16be, Fruit), b"\x01\x00")
            @test serialize(IntEnum(UInt16be, Fruit), orange) == b"\x00\x02"
            @test serialize(IntEnum(UInt16be, Fruit), reinterpret(Fruit, 0x1f)) == b"\x00\x1f"
        end
        @testset "non-exhaustive" begin
            @test_throws TypeError IntEnum{BigEndian}(Fruit)
            @test estimatesize(IntEnum{EnumNonExhaustive}(UInt16be, Fruit)) == sizeof(UInt16)
            @test deserialize(IntEnum{EnumNonExhaustive}(UInt16be, Fruit), b"\x00\x01") == banna
            @test deserialize(IntEnum{EnumNonExhaustive}(UInt16be, Fruit), b"\x00\x1f") == reinterpret(Fruit, 0x1f)
            @test deserialize(IntEnum{EnumNonExhaustive}(Fruit), b"\x1f") == reinterpret(Fruit, 0x1f)
            @test_throws InexactError deserialize(IntEnum{EnumNonExhaustive}(UInt16be, Fruit), b"\x01\x00")
            @test serialize(IntEnum{EnumNonExhaustive}(UInt16be, Fruit), orange) == b"\x00\x02"
            @test serialize(IntEnum{EnumNonExhaustive}(UInt16be, Fruit), reinterpret(Fruit, 0x1f)) == b"\x00\x1f"
        end
    end
    @testset "const" begin
        @testset "deduce type" begin
            @test Constructs.deducetype(() -> Const(0x0102)) <: Construct{UInt16}
            @test Constructs.deducetype(() -> Const(b"BMP")) <: Construct{Vector{UInt8}}
            @test Constructs.deducetype(() -> Const(Int32, 0x0102)) <: Construct{Int32}
            @test Constructs.deducetype(() -> Const(Int32be, 0x0102)) <: Construct{Int32}
        end
        @test estimatesize(Const(0x0102)) == sizeof(0x0102)
        @test estimatesize(Const(b"BMP")) == sizeof(b"BMP")
        @test estimatesize(Const(Int32, 0x0102)) == sizeof(Int32)
        @test estimatesize(Const(Int32be, 0x0102)) == sizeof(Int32)
        @test deserialize(Const(UInt16be, 0x0102), b"\x01\x02") == 0x0102
        @test_throws ValidationError deserialize(Const(UInt16le, 0x0102), b"\x01\x02")
        @test serialize(Const(UInt16be, 0x0102), 0x0102) == b"\x01\x02"
        @test serialize(Const(UInt16be, 0x0102), UndefProperty()) == b"\x01\x02"
        @test_throws ValidationError serialize(Const(0x0102), 0x0201)
    end
    @testset "Overwrite" begin
        @test_throws ArgumentError Overwrite(UInt8, () -> 0x01)
        @test serialize(Overwrite(UInt8, 0x01), 2) == b"\x01"
        @test serialize(Overwrite(UInt8, 0x02), UndefProperty()) == b"\x02"
        @test serialize(Overwrite(Int8, abs), -2) == b"\x02"
        @test serialize(Overwrite(Int8, abs), -2; path=PropertyPath()) == b"\x02"
        @test serialize(Overwrite(Float16le, (v; kw...) -> round(v; digits=get(kw, :digits, 0))), 1.125) == b"\x00\x3c" # Float16(1.0)
        @test serialize(Overwrite(Float16le, (v; kw...) -> round(v; digits=get(kw, :digits, 0))), 1.125; digits=1) == b"\x66\x3c" # Float16(1.1)
        @test serialize(Overwrite(Int8, (v; kw...) -> get(kw, :value, 7)), 6) == b"\x07"
        @test serialize(Overwrite(Int8, (v; kw...) -> get(kw, :value, 7)), 6; value=5) == b"\x05"
        @test_throws MethodError serialize(Overwrite(UInt8, UndefProperty()), 2)
        @test deserialize(Overwrite(UInt8, 0x01), b"\x04") == 0x04
        @test deserialize(Overwrite(UInt8, UndefProperty()), b"\x04") == 0x04
    end
    @testset "conditional" begin
        @testset "Try" begin
            @testset "deduce type" begin
                @test Constructs.deducetype((t1, t2) -> Try(t1, t2), Type{Int}, PrimitiveIO{UInt}) <: Try{Union{Int, UInt}}
                @test Constructs.deducetype((t1, t2) -> Try{Integer}(t1, t2), Type{Int}, PrimitiveIO{UInt}) <: Try{Integer}
                @test Constructs.deducetype((t1, t2, t3) -> Try(t1, t2, t3), Type{Int}, PrimitiveIO{UInt}, Type{Float64}) <: Try{Union{Int, UInt, Float64}}
                @test Constructs.deducetype((t1, t2, t3) -> Try(t1, t2, t3), Padded{UInt, PrimitiveIO{UInt}}, Type{UInt}, Type{Float64}) <: Try{Union{UInt, Float64}}
                @test Constructs.deducetype((t1, t2, t3) -> Try{Real}(t1, t2), Type{Int}, PrimitiveIO{UInt}, Type{Float64}) <: Try{Real}
                @test Constructs.deducetype((t1, t2, t3) -> Try{Number}(t1, t2), Padded{UInt, PrimitiveIO{UInt}}, Type{UInt}, Type{Float64}) <: Try{Number}
            end
            @test_throws MethodError Try{AbstractArray}(Int, UInt)
            @test estimatesize(Try(Padded(UInt, 12), UInt, Missing)) == RangedSize(0, 12)
            @test estimatesize(Try(Padded(UInt, 12), UInt)) == RangedSize(sizeof(UInt), 12)
            @test deserialize(Try(UInt16be, Int8), b"\xfe") == Int8(-2)
            @test deserialize(Try(UInt16be, Int8), b"\xfe\xcc") == 0xfecc
            @test_throws EOFError deserialize(Try(UInt32be, UInt16be), b"\xfe")
            @test_throws ArgumentError deserialize(Try(UInt32be, UInt16be, Fruit), b"\xfe")
            @test serialize(Try(UInt16be, Int8), Int8(-2)) == b"\xfe"
            @test serialize(Try(UInt16be, Int8), 0xfecc) == b"\xfe\xcc"
            @test serialize(Try(Const(UInt16le, 0x0102), UInt16be, Int8), 0xfecc) == b"\xfe\xcc"
            @test serialize(Try(Const(UInt16le, 0x0102), UInt16be, Int8), 0x0102) == b"\x02\x01"
            @test serialize(Try(Const(UInt16le, 0x0102), UInt16be, Int8), UndefProperty()) == b"\x02\x01"
            @test serialize(Try(UInt16be, Const(0xfc)), UndefProperty()) == b"\xfc"
            @test deserialize(Try{Integer}(UInt16be, Int8), b"\xfe") == Int8(-2)
            @test deserialize(Try{Integer}(UInt16be, Int8), b"\xfe\xcc") == 0xfecc
            @test_throws EOFError deserialize(Try{Integer}(UInt32be, UInt16be), b"\xfe")
            @test_throws ArgumentError deserialize(Try{Union{Integer, Base.Enum}}(UInt32be, UInt16be, Fruit), b"\xfe")
            @test serialize(Try{Integer}(UInt16be, Int8), Int8(-2)) == b"\xfe"
            @test serialize(Try{Integer}(UInt16be, Int8), 0xfecc) == b"\xfe\xcc"
            @test serialize(Try{Integer}(UInt32be, UInt16be, Int8), 0xfecc) == b"\xfe\xcc"
            @test_throws MethodError serialize(Try{Integer}(UInt16be, Int8), -2)
        end
    end
    @testset "collections" begin
        @testset "Sequence" begin
            @testset "deduce type" begin
                @test Constructs.deducetype(() -> Sequence()) <: Sequence{Tuple{}}
                @test Constructs.deducetype(t -> Sequence(t), Type{Int}) <: Sequence{Tuple{Int}}
                @test Constructs.deducetype((t1, t2) -> Sequence(t1, t2), Type{Int}, PrimitiveIO{Float64}) <: Sequence{Tuple{Int, Float64}}
                @test Constructs.deducetype((ts...) -> Sequence(ts...),
                        Type{UInt8}, Type{UInt16}, Type{UInt32}, Type{UInt64}, Type{UInt128}, Type{Int8}, Type{Int16}, Type{Int32}, Type{Int64}
                    ) <: Sequence{Tuple{UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64}}
                # In Julia1.6, there is a known issue when the number of Sequence elements is greater than 10
                @static if VERSION >= v"1.7-"
                    @test Constructs.deducetype((ts...) -> Sequence(ts...),
                            Type{UInt8}, Type{UInt16}, Type{UInt32}, Type{UInt64}, Type{UInt128}, Type{Int8}, Type{Int16}, Type{Int32}, Type{Int64}, Type{Int128}
                        ) <: Sequence{Tuple{UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128}}
                else
                    @test_broken Constructs.deducetype((ts...) -> Sequence(ts...),
                        Type{UInt8}, Type{UInt16}, Type{UInt32}, Type{UInt64}, Type{UInt128}, Type{Int8}, Type{Int16}, Type{Int32}, Type{Int64}, Type{Int128}
                    ) <: Sequence{Tuple{UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128}}
                end
            end
            @test Construct(Tuple{}) == Sequence()
            @test Construct(Tuple{Int}) == Sequence(Int)
            @test Construct(Tuple{Int, Float16}) == Sequence(Int, Float16)
            @test Construct(Tuple{UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128}) == Sequence(UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128)
            @test Sequence(Int)[] == Construct(Int)
            @test Sequence(Int, Float16)[2] == Construct(Float16)
            @test Sequence(Int, Padded(Float16, 6))[2] == Padded(Float16, 6)
            @test Sequence(UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128)[10] == Construct(Int128)
            @test estimatesize(Sequence()) == 0
            @test deserialize(Sequence(), UInt8[]) === ()
            @test serialize(()) == UInt8[]
            @test estimatesize(Sequence(Int, Float16)) == estimatesize(Int) + estimatesize(Float16)
            @test estimatesize(Sequence(Int, Padded(Float16, 6))) == estimatesize(Int) + estimatesize(Padded(Float16, 6))
            @test deserialize(Sequence(Padded(Int8, 2), UInt16be), b"\x01\xfe\x01\x02") == (Int8(1), 0x0102)
            @test serialize(Sequence(Padded(Int8, 2), UInt16be), (Int8(1), 0x0102)) == b"\x01\x00\x01\x02"
            @test estimatesize(Sequence(UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128)) == sum(estimatesize, (UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128))
            @test deserialize(
                Sequence(UInt8, UInt16be, UInt32be, UInt64be, UInt128be, Int8, Int16be, Int32be, Int64be, Int128be),
                b"\x01\x00\x02\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05\x06\x00\x07\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x09\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0a"
                ) === (0x01, 0x0002, 0x00000003, 0x0000000000000004, 0x00000000000000000000000000000005, Int8(6), Int16(7), Int32(8), Int64(9), Int128(10))
            @test serialize(
                Sequence(UInt8, UInt16be, UInt32be, UInt64be, UInt128be, Int8, Int16be, Int32be, Int64be, Int128be),
                (0x01, 0x0002, 0x00000003, 0x0000000000000004, 0x00000000000000000000000000000005, Int8(6), Int16(7), Int32(8), Int64(9), Int128(10))
                ) == b"\x01\x00\x02\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x05\x06\x00\x07\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x09\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0a"
        end
        @testset "SizedArray" begin
            @testset "deduce type" begin
                @test Constructs.deducetype(() -> SizedArray(Int, 1, 2)) <: Construct{Array{Int, 2}}
                @test Constructs.deducetype(() -> SizedArray(BitArray{2}, Bool, 1, 2)) <: Construct{BitArray{2}}
                @test Constructs.deducetype((x, y) -> SizedArray(Int, x, y), Int, Int) <: Construct{Array{Int, 2}}
                @test Constructs.deducetype((x, y) -> SizedArray(BitArray{2}, Bool, x, y), Int, Int) <: Construct{BitArray{2}}
                @test Constructs.deducetype((size) -> SizedArray(Int, size), NTuple{3, Int}) <: Construct{Array{Int, 3}}
                @test Constructs.deducetype((size) -> SizedArray(BitArray{5}, Bool, size), NTuple{5, Int}) <: Construct{BitArray{5}}
            end
            @test_throws TypeError SizedArray(BitArray{3}, Int, (2, 3, 5)) # element type mismatch
            @test_throws TypeError SizedArray(UnitRange{Int}, Int, 3) # immutable array cannot be deserialized
            @test_throws TypeError SizedArray(typeof(view([1],1)), Int, 1) # indirect array cannot be deserialized
            @test estimatesize(SizedArray(Int64, ())) == sizeof(Int64)
            @test estimatesize(SizedArray(Int64, 10)) == 10*sizeof(Int64)
            @test estimatesize(SizedArray(Int64, 2, 3, 5)) == 2*3*5*sizeof(Int64)
            @test estimatesize(SizedArray(BitArray{2}, Bool, (2, 3))) == 2*3*sizeof(Bool)
            @test estimatesize(SizedArray(BitArray{3}, Bool, 2, 3, 5)) == 2*3*5*sizeof(Bool)
            @test deserialize(SizedArray(Int8, ()), b"\x02")[] == 2
            @test serialize(SizedArray(Int8, ()), ones(Int8, ())) == b"\x01"
            @test deserialize(SizedArray(Int8, 3), b"\x01\xff\x00") == Int8[1, -1, 0]
            @test serialize(SizedArray(Int8, 3), Int8[1, -1, 0]) == b"\x01\xff\x00"
            @test_throws DimensionMismatch serialize(SizedArray(Int8, 3), Int8[1, -1])
            @test deserialize(SizedArray(Int8, 2, 3), Vector{UInt8}(1:6)) == Int8[1 3 5; 2 4 6]
            @test serialize(SizedArray(Int8, 2, 3), Int8[1 2 3; 4 5 6]) == b"\x01\x04\x02\x05\x03\x06"
        end
        @testset "PrefixedArray" begin
            @testset "deduce type" begin
                @test Constructs.deducetype(() -> PrefixedArray(UInt32, UInt8)) <: Construct{Vector{UInt8}}
                @test Constructs.deducetype(() -> PrefixedArray(Sequence(UInt16, UInt16), UInt8)) <: Construct{Matrix{UInt8}}
                @test Constructs.deducetype(() -> PrefixedArray(BitVector, UInt32, Bool)) <: Construct{BitVector}
                @test Constructs.deducetype(() -> PrefixedArray(BitArray{2}, Sequence(UInt16, UInt16), Bool)) <: Construct{BitArray{2}}
            end
            @test estimatesize(PrefixedArray(UInt32, UInt8)) == UnboundedSize(sizeof(UInt32))
            @test estimatesize(PrefixedArray(Sequence(UInt32, UInt16), UInt8)) == UnboundedSize(sizeof(UInt32) + sizeof(UInt16))
            @test estimatesize(PrefixedArray(BitVector, UInt32, Bool)) == UnboundedSize(sizeof(UInt32))
            @test estimatesize(PrefixedArray(BitArray{2}, Sequence(UInt16, UInt16), Bool)) == UnboundedSize(2 * sizeof(UInt16))
            @test deserialize(PrefixedArray(UInt16le, Int8), b"\x02\x00\x12\xfe") == Int8[18, -2]
            @test serialize(PrefixedArray(UInt16le, Int8), Int8[-3, 1, 7]) == b"\x03\x00\xfd\x01\x07"
            @test deserialize(PrefixedArray(Sequence(UInt8, UInt16le), Int8), b"\x03\x02\x00\xff\xfe\xfd\x01\x02\x03") == Int8[-1 1; -2 2; -3 3]
            @test serialize(PrefixedArray(Sequence(UInt16le, UInt8), Int8), Int8[-3 -2 -1; 1 2 3]) == b"\x02\x00\x03\xfd\x01\xfe\x02\xff\x03"
            @test_throws InexactError serialize(PrefixedArray(Int8, UInt8), collect(0x01:0xff))
        end
        @testset "GreedyVector" begin
            @test estimatesize(GreedyVector(Int8)) == UnboundedSize(0)
            @test deserialize(GreedyVector(Int8), b"\x01\xff\x00") == Int8[1, -1, 0]
            @test serialize(GreedyVector(Int8), Int8[1, -1, 0]) == b"\x01\xff\x00"
            @test serialize(GreedyVector(Int8), UndefProperty()) == b""
            @test deserialize(GreedyVector(UInt16be), b"\x01\xff\x02\xab\xcc") == [0x01ff, 0x02ab]
            @test serialize(GreedyVector(UInt16be), [0x01ff, 0xcc0a]) == b"\x01\xff\xcc\x0a"
            @test_throws ExceedMaxIterations deserialize(GreedyVector(Nothing), b"\x00")
            @test_throws ExceedMaxIterations deserialize(GreedyVector(Int8), Vector{UInt8}(1:10); max_iter=9)
        end
    end
    @testset "Padded" begin
        @test estimatesize(Padded(5)) == 5
        @test estimatesize(Padded(Int16, 5)) == 5
        @test deserialize(Padded(Int8, 2), b"\x01\xfc") == Int8(1)
        @test serialize(Padded(Int8, 2), Int8(1)) == b"\x01\x00"
        @test_throws PaddedError deserialize(Padded(Int32, 3), b"\x01\x02\x03\x04")
        @test_throws PaddedError serialize(Padded(Int32, 3), Int32(1))
        @test deserialize(Padded(2), b"\x01\xff") === nothing
        @test serialize(Padded(2), nothing) == b"\x00\x00"
        @test serialize(Padded(2), UndefProperty()) == b"\x00\x00"
    end
    @testset "internal" begin
        @testset "sym macro" begin
            @test let x
                Constructs.@sym x
                x == :x
            end
            @test let x, symbol
                Constructs.@sym x symbol
                x == :x && symbol == :symbol
            end
        end
        constructypecases = Tuple{Union{Type, Construct}, Type}[
            (Int32, Int32),
            (JuliaSerializer(), Any),
            (Padded(4), Nothing),
            (UInt64be, UInt),
            (Const(0x0102), UInt16),
            (Const(b"BMP"), Vector{UInt8}),
            (Try(Int, UInt), Union{Int, UInt}),
            (Try{Integer}(Int, UInt), Integer),
            (Try(Padded(UInt, 12), UInt, Missing), Union{Missing, UInt}),
            (Sequence(), Tuple{}),
            (Sequence(Float64le), Tuple{Float64}),
            (Sequence(Float64be, UInt64be), Tuple{Float64, UInt}),
            (SizedArray(Int), Array{Int, 0}),
            (SizedArray(Float64, 10), Array{Float64, 1}),
            (SizedArray(UInt16be, 5, 17), Array{UInt16, 2}),
            (GreedyVector(Int), Vector{Int})
        ]
        @testset "construct type" for (cons, type) in constructypecases
            @test Constructs.constructtype(cons) == type
            @test Constructs.constructtype2(cons isa Type ? Type{cons} : typeof(cons)) == type
        end
    end
    @testset "@construct macro expand" begin # just check macro expanding
        abstract type AbstractImage end
        structonly = quote
            @construct struct Bitmap <: AbstractImage
                signature::Const(b"BMP")
                width::UInt32
                height::UInt32
                ::Padded(8)
                pixel::SizedArray(UInt8, this.height, this.width)
            end
        end
        withname = quote
            @construct BitmapConstruct struct Bitmap <: AbstractImage
                signature::Const(b"BMP")
                width::UInt32
                height::UInt32
                ::Padded(8)
                pixel::SizedArray(UInt8, this.height, this.width)
            end
        end
        @testset "expand pass" for ex in [structonly, withname]
            @test @capture @show(macroexpand(@__MODULE__, ex)) begin
                begin
                    doc_
                    struct ST_ stfields__ end
                end
                struct CT_ <: Construct_{STT_} end
                function Construct_(::Type_{STT_})
                    CTT_()
                end
                function serialize_(::CTT_, ss_::IO_, val_::STT_; scontextkw_...)
                    serializebody__
                end
                function deserialize_(::CTT_, ds_::IO_; dcontextkw_...)
                    deserializebody__
                end
                function estimatesize_(::CTT_; econtextkw_...)
                    estimatesizebody__
                end
            end
        end
        notstruct = (
            ErrorException,
            quote
                @construct abstract type Bitmap <: AbstractImage end
            end
        )
        missingtype = (
            ErrorException,
            quote
                @construct struct Bitmap <: AbstractImage
                    signature::Const(b"BMP")
                    width::UInt32
                    height::UInt32
                    rest
                end
            end
        )
        deducefailed = (
            ErrorException,
            quote
                @construct struct Bitmap <: AbstractImage
                    signature::Const(b"BMP")
                    width::UInt32
                    height::UInt32
                    ::Padded(8)
                    pixel::SizedArray(UInt8, this.signature, this.width)
                end
            end
        )
        nodefaultconstruct = (
            MethodError,
            quote
                @construct struct Bitmap <: AbstractImage
                    signature::Const(b"BMP")
                    width::UInt32
                    height::UInt32
                    rest::Any
                end
            end
        )
        @testset "expand error" for (err, ex) in [notstruct, missingtype, deducefailed, nodefaultconstruct]
            @static if Base.VERSION >= v"1.7-"
                @test_throws err macroexpand(@__MODULE__, ex)
            else
                @test_throws LoadError macroexpand(@__MODULE__, ex)
            end
        end
        @testset "Bitmap1" begin
            @construct struct Bitmap1 <: AbstractImage
                signature::Const(b"BMP")
                ::Padded(1)
                width::UInt16le
                height::UInt16le
                pixel::SizedArray(UInt8, this.height, this.width)
            end
            @test Bitmap1 <: AbstractImage
            @test fieldnames(Bitmap1) == (:signature, :width, :height, :pixel)
            @test fieldtype(Bitmap1, :signature) == Vector{UInt8}
            @test fieldtype(Bitmap1, :width) == UInt16
            @test fieldtype(Bitmap1, :pixel) == Matrix{UInt8}
            @test estimatesize(Bitmap1) == UnboundedSize(sizeof(b"BMP") + 1 + 2 * sizeof(UInt16))
            @test serialize(Bitmap1(b"BMP", 3, 2, UInt8[1 2 3; 7 8 9])) == b"BMP\x00\x03\x00\x02\x00\x01\x07\x02\x08\x03\x09"
            @test let res = deserialize(Bitmap1, b"BMP\xfe\x03\x00\x02\x00\x01\x07\x02\x08\x03\x09")
                res.signature == b"BMP" && res.width == 3 && res.height == 2 && res.pixel == UInt8[1 2 3; 7 8 9]
            end
            @test_throws DimensionMismatch serialize(Bitmap1(b"BMP", 3, 2, UInt8[1 2; 7 8]))
            @test_throws ValidationError serialize(Bitmap1(b"PMB", 3, 2, UInt8[1 2 3; 7 8 9]))
            @test_throws EOFError deserialize(Bitmap1, b"BMP\xfe\x03\x00\x02\x00\x01\x07\x02\x08\x03")
            @test_throws ValidationError deserialize(Bitmap1, b"PMB\xfe\x03\x00\x02\x00\x01\x07\x02\x08\x03\x09")
        end
    end
end
