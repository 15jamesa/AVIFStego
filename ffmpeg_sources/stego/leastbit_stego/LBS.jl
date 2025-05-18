module LBS

using ImageIO, FileIO, ColorTypes, ImageView, Images, Faker

export encode, decode, message_to_bin, bin_to_message, qcoeffs_to_bin, bin_to_qcoeffs, generate_m, messaging, encode_avif
function encode(img, secret_message)
    #change last bit
    for i in eachindex(secret_message)
        #clear bit
        img[i] = img[i] & (-2)
        #set bit
        img[i] = img[i] ⊻ secret_message[i]
    end

    return img
end

function decode(y)

    extracted = [mod(x,2) for x in y]

    #make sense of extracted data
    characters = join(Char.(parse.(Int, (join.(collect(Iterators.partition(extracted, 8)))); base=2)))
    return characters

end

function message_to_bin(message)
    message_bin = parse.(Int, collect(join(bitstring.(Int8.(collect(message))))))
    return message_bin
end

function bin_to_message(binary)
    characters = join(Char.(parse.(Int, (join.(collect(Iterators.partition(binary, 8)))); base=2)))
    return characters
end

function qcoeff_to_bin(qcoeffs)
    coeffs = Int32.(qcoeffs)
    bits = parse.(Int64,reduce(vcat, split.(bitstring.(coeffs), "")))
    return bits
end

function generate_m(bits)
    message = Faker.text(number_chars=div(b,8))
    message_bin = parse.(Int, collect(join(bitstring.(Int8.(collect(message))))))
    return message_bin
end 

function encode_avif(coeff, m_bit)
    c = coeff
    b = m_bit
    s = Int32.(encode(c,b))
    return (s)
end

function encode_spatial(img, secret_message)
    m = message_to_bin(secret_message)
    width = size(img)[1]
    height = size(img)[2]

    #reshape image into 1D + isolate blue channel
    reshape(img, (1, (width*height)))
    b = UInt8.(reinterpret.(blue.(img)))

    b = encode(b, m)

    #add blue channel back 
    for j in eachindex(b)
        pixel = img[j]
        img[j] = RGBA(red(pixel), green(pixel), reinterpret(N0f8,b[j]), alpha(pixel))
    end
    
    #reshape to image shape
    reshape(img, (height, width))

    return img
end

function decode_spatial(img)
    width = size(img)[1]
    height = size(img)[2]
    reshape(img, (1, (width*height)))

    #extract data
    b = UInt8.(reinterpret.(blue.(img)))
    message = decode(b)

    return message
end
end

