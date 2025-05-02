include("../Embedding Cost Functions/Pixel_Weight_Functions.jl")
include("../Least-Bit Stego/LBS.jl")
using .PixelWeights
using .LBS
using Images, FileIO, Plots, ImageDistances, StatsPlots, Statistics, Faker
gr()

function SSIM_plot(test_image_folder)
    cd(test_image_folder)
    
    for i in 1:5
        image = "original_" * string(i) * ".png"
        upper = 204800
        interval = 10240
        xvalues = [l for l in 1:interval:upper]
        yvalues = ones(length(xvalues))
        x = load(image)
        for m in interval:interval:upper
            message = Faker.text(number_chars=div(m,8))
            y = LBS.encode(x, message)
            yvalues[div(m,interval)] = assess_ssim(RGB.(x), RGB.(y))
            if m == upper
                println(LBS.decode(y))
            end
        end


        plot(xvalues, yvalues)
        savefig("test.png")
        exit()
    end
end

#boxplots?
function noise_estimation_plot(image_names)
    categories = repeat(["Border Noise", "Central Noise"], inner=4)
    name = repeat(["Sunflower", "Gerbera", "Nigella", "Sweet William"], outer=2)
    averages = zeros(8)
    stds = zeros(8)
    estimating_functions= ["blurred_noise_calculation","colour_sensitivity", "canny_edge_detection", "fourier_hard_cutoff_filtering", "fourier_soft_cutoff_filtering"]
    plot_array = Array{Plots.Plot{Plots.GRBackend},1}(undef,length(estimating_functions)+1)
    titles = ["Blurred Noise", "Colour Sensitivity", "Edge Detection", "Fourier Hard Cutoff", "Fourier Soft Cutoff"]

    for func in eachindex(estimating_functions)
        for image in eachindex(image_names)
            x = load(image_names[image])
            width,height = div.(size(x),2)
            y = getfield(PixelWeights, Symbol(estimating_functions[func]))(x)
            val1 = y[1:10, 1:10]
            val2 = y[width:(width+10), height:(height+10)]
            averages[image] = mean(val1, dims=(1,2))[1]
            averages[image+4] = mean(val2, dims=(1,2))[1]
            stds[image] = std(val1, dims=(1,2))[1]
            stds[image+4] = std(val2, dims=(1,2))[1]
        end 

        plot_array[func] = groupedbar(name, averages, yerr=stds, group = categories, ylabel = "Average Noise Value",
           title = titles[func], bar_width = 0.67, 
           markerstrokewidth = 1.5, ylims=(0, :auto), legend=false,
           framestyle = :box, grid = false, xrotation=30, guidefont=10, leftmargin=10Plots.mm, rightmargin=10Plots.mm, bottommargin=10Plots.mm)

    end

    println("normal arrays done")
    temp = [-10 -20; -30 -40 ]
    plot_array[6] = plot(temp, ylims = (0,3), xlims=(0,3), legend=:topleft,
     label = ["Noise at Border" "Noise at Centre"], framestyle=:none, grid=false, legendfontsize=16, markersize = 16)
    println("legend")

    plot(plot_array..., layout=(2,3), size=(1200,800))
    savefig("noise_estimate.png")
end

function canny_noise_estimation_plot(image_names)
    categories = repeat(["Border Noise", "Central Noise"], inner=4)
    name = repeat(["Sunflower", "Gerbera", "Nigella", "Sweet William"], outer=2)
    averages = zeros(8)
    stds = zeros(8)

    for image in eachindex(image_names)
        x = load(image_names[image])
        width,height = div.(size(x),2)
        y = PixelWeights.canny_edge_detection(x)
        val1 = y[1:10, 1:10]
        val2 = y[width:(width+10), height:(height+10)]
        averages[image] = mean(val1, dims=(1,2))[1]
        averages[image+4] = mean(val2, dims=(1,2))[1]
        stds[image] = std(val1, dims=(1,2))[1]
        stds[image+4] = std(val2, dims=(1,2))[1]
    end 

    groupedbar(name, averages, yerr=stds, group = categories, ylabel = "Average Noise Value",
        title = "Edge Detection", bar_width = 0.67, 
        markerstrokewidth = 1.5, ylims=(0, :auto), legend=true,
        framestyle = :box, grid = false, xrotation=30, guidefont=10, leftmargin=10Plots.mm, rightmargin=10Plots.mm, bottommargin=10Plots.mm)

    savefig("canny_noise_estimate.png")
end

cd("../Evaluation")
SSIM_plot("../Test_Data")
