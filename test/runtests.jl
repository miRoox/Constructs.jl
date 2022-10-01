using Constructs
using Intervals
using Test

@testset "Constructs.jl" begin
    @testset "container" begin
        @test_throws ArgumentError Container(1)
        @test Container(im).im
        @test_throws ErrorException Container(im).im = false
        @test propertynames(Container(1//2)) == propertynames(1//2)
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
        @testset "SizedArray" begin
            @test_throws TypeError SizedArray(BitArray{3}, Int, 2, 3, 5) # element type mismatch
            @test_throws TypeError SizedArray(UnitRange{Int}, Int, 3) # immutable array cannot be deserialized
            @test_throws TypeError SizedArray(typeof(view([1],1)), Int, 1) # indirect array cannot be deserialized
            @test estimatesize(SizedArray(Int64)) == sizeof(Int64)
            @test estimatesize(SizedArray(Int64, 10)) == 10*sizeof(Int64)
            @test estimatesize(SizedArray(Int64, 2, 3, 5)) == 2*3*5*sizeof(Int64)
            @test estimatesize(SizedArray(BitArray{3}, Bool, 2, 3, 5)) == 2*3*5*sizeof(Bool)
            @test deserialize(SizedArray(Int8), [0x02])[] == 2
            @test serialize(SizedArray(Int8), ones(Int8)) == [0x01]
            @test deserialize(SizedArray(Int8, 3), [0x01, 0xff, 0x00]) == Int8[1, -1, 0]
            @test serialize(SizedArray(Int8, 3), Int8[1, -1, 0]) == [0x01, 0xff, 0x00]
            @test_throws DimensionMismatch serialize(SizedArray(Int8, 3), Int8[1, -1])
            @test deserialize(SizedArray(Int8, 2, 3), Vector{UInt8}(1:6)) == Int8[1 3 5; 2 4 6]
            @test serialize(SizedArray(Int8, 2, 3), Int8[1 2 3; 4 5 6]) == [0x01, 0x04, 0x02, 0x05, 0x03, 0x06]
        end
        @testset "GreedyVector" begin
            @test estimatesize(GreedyVector(Int8)) == Interval(UInt(0), nothing)
            @test deserialize(GreedyVector(Int8), [0x01, 0xff, 0x00]) == Int8[1, -1, 0]
            @test serialize(GreedyVector(Int8), Int8[1, -1, 0]) == [0x01, 0xff, 0x00]
            @test deserialize(GreedyVector(BigEndian(UInt16)), [0x01, 0xff, 0x02, 0xab, 0xcc]) == [0x01ff, 0x02ab]
            @test serialize(GreedyVector(BigEndian(UInt16)), [0x01ff, 0xcc0a]) == [0x01, 0xff, 0xcc, 0x0a]
            @test_throws ExceedMaxIterations deserialize(GreedyVector(Nothing), [0x00])
            @test_throws ExceedMaxIterations deserialize(GreedyVector(Int8), Vector{UInt8}(1:10); max_iter=9)
        end
    end
    @testset "padded" begin
        @test estimatesize(Padded(5)) == 5
        @test estimatesize(Padded(Int16, 5)) == 5
        @test deserialize(Padded(Int8, 2), [0x01, 0xff]) == Int8(1)
        @test serialize(Padded(Int8, 2), Int8(1)) == [0x01, 0x00]
        @test_throws PaddedError deserialize(Padded(Int32, 3), [0x01, 0x02, 0x03, 0x04])
        @test_throws PaddedError serialize(Padded(Int32, 3), Int32(1))
        @test deserialize(Padded(2), [0x01, 0xff]) === nothing
        @test serialize(Padded(2), nothing) == [0x00, 0x00]
    end
    @testset "internal" begin
        @testset "deduce type" begin
            @test Constructs.deducetype(() -> SizedArray(Int, 1, 2)) == SizedArray{Int, 2, Array{Int, 2}, PrimitiveIO{Int}}
            @test Constructs.deducetype(() -> SizedArray(BitArray{2}, Bool, 1, 2)) == SizedArray{Bool, 2, BitArray{2}, PrimitiveIO{Bool}}
            @test Constructs.deducetype((x, y) -> SizedArray(Int, x, y), Int, Int) == SizedArray{Int, 2, Array{Int, 2}, PrimitiveIO{Int}}
            @test Constructs.deducetype((x, y) -> SizedArray(BitArray{2}, Bool, x, y), Int, Int) == SizedArray{Bool, 2, BitArray{2}, PrimitiveIO{Bool}}
        end
        constructypecases = Tuple{Union{Type, Construct}, Type}[
            (Int32, Int32),
            (JuliaSerializer(), Any),
            (Padded(4), Nothing),
            (BigEndian(UInt), UInt),
            (Const(0x0102), UInt16),
            (Const(b"BMP"), Vector{UInt8}),
            (SizedArray(Int), Array{Int, 0}),
            (SizedArray(Float64, 10), Array{Float64, 1}),
            (SizedArray(BigEndian(UInt16), 5, 17), Array{UInt16, 2}),
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
                pixel::SizedArray(UInt8, this.width, this.height)
            end
        end
        withname = quote
            @construct BitmapConstruct struct Bitmap <: AbstractImage
                signature::Const(b"BMP")
                width::UInt32
                height::UInt32
                ::Padded(8)
                pixel::SizedArray(UInt8, this.width, this.height)
            end
        end
        @testset "expand pass" for ex in [structonly, withname]
            @inferred Expr macroexpand(@__MODULE__, ex)
        end
        notstruct = quote
            @construct abstract type Bitmap <: AbstractImage end
        end
        missingtype = quote
            @construct struct Bitmap <: AbstractImage
                signature::Const(b"BMP")
                width::UInt32
                height::UInt32
                rest
            end
        end
        deducefailed = quote
            @construct struct Bitmap <: AbstractImage
                signature::Const(b"BMP")
                width::UInt32
                height::UInt32
                ::Padded(8)
                pixel::SizedArray(UInt8, (this.width, this.height))
            end
        end
        @testset "expand error" for ex in [notstruct, missingtype, deducefailed]
            @test_throws LoadError macroexpand(@__MODULE__, ex)
        end
    end
end
