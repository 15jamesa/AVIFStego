include("/home/avajames/ffmpeg_sources/stego/embedding_cost_functions/Pixel_Weight_Functions.jl")
using .PixelWeights
using Test
using Images
using Statistics

@testset "blurred" begin
    x = load("sunflower.png")
    y = PixelWeights.blurred_noise_calculation(x)
    width,height = div.(size(x),2)
    @test mean(y[1:10, 1:10], dims=(1,2))[1] < mean(y[width:(width+10), height:(height+10)], dims=(1,2))[1]

    @test minimum(y) >= 0
end

@testset "sensitivity" begin
    x = load("sunflower.png")
    y = PixelWeights.colour_sensitivity(x)
    width,height = div.(size(x),2)
    @test mean(y[1:10, 1:10], dims=(1,2))[1] < mean(y[width:(width+10), height:(height+10)], dims=(1,2))[1]

    @test minimum(y) >= 0
end

@testset "canny" begin
    x = load("sunflower.png")
    y = PixelWeights.canny_edge_detection(x)
    width,height = div.(size(x),2)
    @test mean(y[1:10, 1:10], dims=(1,2))[1] < mean(y[width:(width+10), height:(height+10)], dims=(1,2))[1]

    @test minimum(y) >= 0
end

@testset "hard-cutoff" begin
    x = load("sunflower.png")
    y = PixelWeights.fourier_hard_cutoff_filtering(x)
    width,height = div.(size(x),2)
    @test mean(y[1:10, 1:10], dims=(1,2))[1] < mean(y[width:(width+10), height:(height+10)], dims=(1,2))[1]

    @test minimum(y) >= 0
end

@testset "soft-cutoff" begin
    x = load("sunflower.png")
    y = PixelWeights.fourier_soft_cutoff_filtering(x)
    width,height = div.(size(x),2)
    @test mean(y[1:10, 1:10], dims=(1,2))[1] < mean(y[width:(width+10), height:(height+10)], dims=(1,2))[1]

    @test minimum(y) >= 0
end

@testset "pad" begin
    #odd dimensions
    @test parent(PixelWeights.add_padding([1 1 1; 1 1 1; 1 1 1])) == [1 1 1 1 1 1 1; 1 1 1 1 1 1 1; 1 1 1 1 1 1 1; 1 1 1 1 1 1 1; 1 1 1 1 1 1 1; 1 1 1 1 1 1 1; 1 1 1 1 1 1 1]
    #even dimensions
    @test parent(PixelWeights.add_padding([1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1])) == [1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1]
end

@testset "unpad" begin
    #odd dimensions
    @test PixelWeights.remove_padding(PixelWeights.add_padding([1 1 1; 1 1 1; 1 1 1])) == [1 1 1; 1 1 1; 1 1 1]
    #even dimensions
    @test PixelWeights.remove_padding(PixelWeights.add_padding([1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1])) == [1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1]
end