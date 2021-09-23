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
        @test length(transcode(UInt8, [codepoint(c)])) in estimatesize(Char)
        @test deserialize(Char, transcode(UInt8, [codepoint(c)])) == c
        @test serialize(c) == transcode(UInt8, [codepoint(c)])
    end
end
