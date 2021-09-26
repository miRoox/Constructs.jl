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
    @testset "macro" begin
        @testset "cons" begin
            @test @cons(Default(Int)) == Int
            @test @cons(JuliaSerializer()) == Any
            @test @cons(Padding(4)) == Nothing
            @test @cons(BigEndian(UInt)) == UInt
        end
    end
end
