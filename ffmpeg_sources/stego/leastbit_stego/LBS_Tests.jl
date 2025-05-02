include("LBS.jl")
using .LBS
using Test

cd("./Least-Bit Stego/")
@testset "embedding_and_extracting_correctness" begin
    #colour photo
    LBS.encode("dice.png", "this is my super secret message!", "secret_image.png")
    #file was created
    @test "secret_image.png" in readdir()
    #message can be extracted
    @test LBS.decode("secret_image.png")[1:32] == "this is my super secret message!"
    rm("secret_image.png")

    #black and white photo
    LBS.encode("boat.png", "this is my super secret message!", "secret_image.png")
    #file was created
    @test "secret_image.png" in readdir()
    #message can be extracted
    @test LBS.decode("secret_image.png")[1:32] == "this is my super secret message!"
    rm("secret_image.png")

end
