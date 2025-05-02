include("STC.jl")
using .STC
using Test

@testset "embedding_correctness" begin
    #even dimension matrix
    @test STC.embed([1,2], [0,1,1,1,1,0,1,1,1,1], [0,1,1,0,1], [1,1,1,1,1,1,1,1,1,1])[2] == [0,1,0,1,0,0,0,1,0,1]
    #uneven dimension matrix
    @test STC.embed([1,2,0], [1,0,1,0,0,1,1,1,0,0,1,0,0,1,0], [0,1,0,0,1], [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1])[2] == [0,1,1,0,0,1,0,0,0,0,1,0,0,1,0]
end

@testset "extracting_correctness" begin
    #even dimension matrix
    @test STC.matrix_mult([7,4,3], [0,1,1,0,1,0,1,1,1,1,1,0,0,0,0]) == [1,1,1,0,1]
    #uneven dimension matrix
    @test STC.matrix_mult([1,6], [1,1,1,1,1,0,1,1,0,1]) == [1,0,1,0,1]
end

@testset "embed_and_extract_correctness" begin
    #even dimension matrix
    @test STC.matrix_mult([11,15,13,9],STC.embed([11,15,13,9], [0,0,1,0,0,1,0,0,0,0,1,1,0,1,1,1,1,0,1,0], [1,1,1,0,1], [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1])[2]) == [1,1,1,0,1]
    #uneven dimension matrix
    @test STC.matrix_mult([1,4], STC.embed([1,4], [0,0,0,1,1,0,1,1,0,1], [1,1,0,0,0], [1,1,1,1,1,1,1,1,1,1])[2]) == [1,1,0,0,0]
end

@testset "kth_bit_function" begin
    #LSB
    @test STC.get_kth_bit(0,9) == 1
    #Random bit
    @test STC.get_kth_bit(2, 123) == 0
    #MSB
    @test STC.get_kth_bit(3,8) ==1
end