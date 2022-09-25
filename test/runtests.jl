using Constructs
using Intervals
using Test

@testset "Constructs.jl" begin
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
        end
        @testset "non-singleton type $type" for type in (Bool, Union{}, Char, DataType)
            @test_throws ArgumentError Singleton(type)
        end
    end
    @testset "byte order" begin
        be = (
            (0x0102, [0x01, 0x02]),
            (0x01020304, [0x01, 0x02, 0x03, 0x04]),
            (0x0102030405060708, [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]),
            (Int32(-2140118960), [0x80, 0x70, 0x60, 0x50]),
            (Inf16, [0x7c, 0x00]),
            (Float32(-1.1), [0xbf, 0x8c, 0xcc, 0xcd]),
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
    @testset "enum" begin
        @enum Fruit::Int8 begin
            apple
            banna
            orange
        end
        @testset "auto type" begin
            @test estimatesize(Fruit) == sizeof(Int8)
            @test deserialize(Fruit, [0x01]) == banna
            @test serialize(orange) == [0x02]
        end
        @testset "override base type" begin
            @test estimatesize(IntEnum(UInt8, Fruit)) == sizeof(UInt8)
            @test deserialize(IntEnum(UInt8, Fruit), [0x01]) == banna
            @test serialize(IntEnum(UInt8, Fruit), orange) == [0x02]
        end
        @testset "override base type construct" begin
            @test estimatesize(IntEnum(BigEndian(UInt16), Fruit)) == sizeof(UInt16)
            @test deserialize(IntEnum(BigEndian(UInt16), Fruit), [0x00, 0x01]) == banna
            @test serialize(IntEnum(BigEndian(UInt16), Fruit), orange) == [0x00, 0x02]
        end
    end
    @testset "const" begin
        @test estimatesize(Const(0x0102)) == sizeof(0x0102)
        @test estimatesize(Const(b"BMP")) == sizeof(b"BMP")
        @test estimatesize(Const(Int32, 0x0102)) == sizeof(Int32)
        @test estimatesize(Const(BigEndian(Int32), 0x0102)) == sizeof(Int32)
        @test deserialize(Const(BigEndian(UInt16), 0x0102), [0x01, 0x02]) == 0x0102
        @test_throws ValidationError deserialize(Const(LittleEndian(UInt16), 0x0102), [0x01, 0x02])
        @test serialize(Const(BigEndian(UInt16), 0x0102), 0x0102) == [0x01, 0x02]
        @test_throws ValidationError serialize(Const(0x0102), 0x0201)
    end
    @testset "collections" begin
        @testset "Array" begin
            @test estimatesize(SizedArray(Int64)) == sizeof(Int64)
            @test estimatesize(SizedArray(Int64, 10)) == 10*sizeof(Int64)
            @test estimatesize(SizedArray(Int64, 2, 3, 5)) == 2*3*5*sizeof(Int64)
            @test deserialize(SizedArray(Int8, 3), [0x01, 0xff, 0x00]) == Int8[1, -1, 0]
            @test serialize(SizedArray(Int8, 3), Int8[1, -1, 0]) == [0x01, 0xff, 0x00]
            @test deserialize(SizedArray(Int8, 2, 3), Vector{UInt8}(1:6)) == Int8[1 3 5; 2 4 6]
            @test serialize(SizedArray(Int8, 2, 3), Int8[1 2 3; 4 5 6]) == [0x01, 0x04, 0x02, 0x05, 0x03, 0x06]
        end
        @testset "GreedyVector" begin
            @test estimatesize(GreedyVector(Int8)) == Interval(UInt(0), nothing)
            @test deserialize(GreedyVector(Int8), [0x01, 0xff, 0x00]) == Int8[1, -1, 0]
            @test serialize(GreedyVector(Int8), Int8[1, -1, 0]) == [0x01, 0xff, 0x00]
            @test deserialize(GreedyVector(BigEndian(UInt16)), [0x01, 0xff, 0x02, 0xab, 0xcc]) == [0x01ff, 0x02ab]
            @test serialize(GreedyVector(BigEndian(UInt16)), [0x01ff, 0xcc0a]) == [0x01, 0xff, 0xcc, 0x0a]
        end
    end
    @testset "internal" begin
        @testset "construct type" begin
            @test Constructs.constructtype(Int32) == Int32
            @test Constructs.constructtype(JuliaSerializer()) == Any
            @test Constructs.constructtype(Padding(4)) == Nothing
            @test Constructs.constructtype(BigEndian(UInt)) == UInt
            @test Constructs.constructtype(Const(0x0102)) == UInt16
            @test Constructs.constructtype(Const(b"BMP")) == Vector{UInt8}
            @test Constructs.constructtype(SizedArray(Int)) == Array{Int, 0}
            @test Constructs.constructtype(SizedArray(Float64, 10)) == Array{Float64, 1}
            @test Constructs.constructtype(SizedArray(BigEndian(UInt16), 5, 17)) == Array{UInt16, 2}
        end
    end
    @testset "macro expand" begin # just check if there is any error raised during macro expanding
        structonly = quote
            @construct struct Bitmap
                signature::Const(b"BMP")
                width::UInt32
                height::UInt32
                ::Padding(8)
                pixel::SizedArray(UInt8, this.width, this.height)
            end
        end
        withname = quote
            @construct BitmapConstruct struct Bitmap
                signature::Const(b"BMP")
                width::UInt32
                height::UInt32
                ::Padding(8)
                pixel::SizedArray(UInt8, this.width, this.height)
            end
        end
        @testset "@construct" for ex in [structonly, withname]
            @inferred Expr macroexpand(@__MODULE__, ex)
        end
    end
end
