using Constructs
using Test

@testset "Constructs.jl" begin
    @testset "primitive type $type" for type in (Bool, UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128, Float16, Float32, Float64)
        @test estimatesize(type) == sizeof(type)
        @test deserialize(type, zeros(UInt8, sizeof(type))) == zero(type)
        @test serialize(zero(type)) == zeros(UInt8, sizeof(type))
    end
    @testset "empty type $type" for type in (Nothing, Missing)
        @test estimatesize(type) == 0
        @test deserialize(type, UInt8[]) === type.instance
        @test serialize(type.instance) == UInt8[]
    end
    @testset "char $c" for c in ['\x00', 'A', 'α', '啊', '🆗']
        codes = transcode(UInt8, [codepoint(c)])
        @test length(codes) in estimatesize(Char)
        @test deserialize(Char, codes) == c
        @test serialize(c) == codes
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
    @testset "magic" begin
        @test estimatesize(Magic(0x0102)) == sizeof(0x0102)
        @test estimatesize(Magic(Int32, 0x0102)) == sizeof(Int32)
        @test estimatesize(Magic(BigEndian(Int32), 0x0102)) == sizeof(Int32)
        @test deserialize(Magic(BigEndian(UInt16), 0x0102), [0x01, 0x02]) == 0x0102
        @test_throws ValidationError deserialize(Magic(LittleEndian(UInt16), 0x0102), [0x01, 0x02])
        @test serialize(Magic(BigEndian(UInt16), 0x0102), 0x0102) == [0x01, 0x02]
        @test_throws ValidationError serialize(Magic(0x0102), 0x0201)
    end
    @testset "macro" begin
        @testset "cons" begin
            @test @cons(Default(Int)) == Int
            @test @cons(JuliaSerializer()) == Any
            @test @cons(Padding(4)) == Nothing
            @test @cons(BigEndian(UInt)) == UInt
        end
    end
end
