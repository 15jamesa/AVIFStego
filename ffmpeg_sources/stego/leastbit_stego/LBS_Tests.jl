include("/home/avajames/ffmpeg_sources/stego/leastbit_stego/LBS.jl")
using .LBS
using Test

cd("./Least-Bit Stego/")
@testset "embedding_and_extracting_correctness" begin
    #colour photo
    x = LBS.spatial_encode("dice.png", "this is my super secret message!")
    save("secret_image.png", x)
    #file was created
    @test "secret_image.png" in readdir()
    #message can be extracted
    y = load("secret_image.png")
    @test LBS.spatial_decode(y)[1:32] == "this is my super secret message!"
    rm("secret_image.png")

    #black and white photo
    x = LBS.spatial_encode("boat.png", "this is my super secret message!")
    save("secret_image.png", x)
    #file was created
    @test "secret_image.png" in readdir()
    #message can be extracted
    y = load("secret_image.png")
    @test LBS.decode(y)[1:32] == "this is my super secret message!"
    rm("secret_image.png")

end
