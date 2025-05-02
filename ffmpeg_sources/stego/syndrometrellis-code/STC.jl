module STC

using SparseArrays

#generate h_hat to be shared with sender and receiver
function generate_h_hat(h,w)
    h_hat = rand([0,1],(h,w))
    return h_hat
end

#finds the y most similar to x that satisfies Hy = m
function embed(h_hat, x, m, rho)
    #reads columns upwards
    #forward step of viterbi
    w = length(h_hat)
    h = ndigits(maximum(h_hat), base=2)
    n = length(x)
    block_num = div(n, w)
    path = zeros(Bool, n, h^2)
    y = zeros(Int64, n)

    weight = [Inf32 for n in 1:2^h]
    weight[1] = 0
    indx = 1
    indm = 1
    limit = block_num - (h-1)
    for i in 1:block_num
        for j in 1:w
            new_weight = zero(weight)
            for k in 1:(2^h)
                w0 = weight[k] + x[indx]*rho[indx]
                column = i > limit ? h_hat[j] & (1 << (h-(i-limit))-1) : h_hat[j]
                ind = ((k-1) ⊻ column)+1
                w1 = weight[ind] + (1-x[indx])*rho[indx]
                path[indx, k] = w1 < w0 ? 1 : 0
                new_weight[k] = min(w0,w1)
            end
            indx += 1
            weight=new_weight
        end
        for j in 0:2^(h-1)-1
            weight[j+1] = weight[2*j + m[indm] + 1]
        end
        for n in 2^(h-1):2^h-1; weight[n+1] = Inf; end
        indm += 1
    end
    #backward step of viterbi
    embedding_cost = weight[1]
    state = 0
    indx -= 1
    indm -= 1
    for i in block_num:-1:1
        state = 2*state + m[indm]
        for j in w:-1:1
            y[indx] = path[indx, (state+1)]
            column = i > limit ? h_hat[j] & (1 << (h-(i-limit))-1) : h_hat[j]
            state = state ⊻ (y[indx]*column)
            indx -= 1
        end
        indm -= 1
    end
    return (embedding_cost, y)
end


#=create the sparse matrix
function expand_h_hat(h_hat, y)
    w = length(h_hat)
    h = ndigits(maximum(h_hat), base=2)
    block_num = div(size(y)[1],w)
    H = spzeros(Int64, block_num, size(y)[1])
    limit = (block_num)-(h-1)
    for i in 1:(size(y)[1])
        block = i/w
        o = ceil(Int, block)
        j = mod(i-1,w) +1
        column = block > limit ? h_hat[j] & (1 << (h-(o-limit))-1) : h_hat[j]
        cutoff = block > limit ? h-(1-limit) : o+h-1
        column = digits(column, base=2, pad=(cutoff-o+1))
        H[o:cutoff,i] = column
    end
    return H
end

#bitwise matrix multiplication
function extract(h_hat,y)
    H = expand_h_hat(h_hat,y)
    message = zeros(Int64, size(H,1))
    for (i,row) in enumerate(eachrow(H))
        combined = row .& y
        ones = sum(combined)
        message_bit = mod(ones,2)==0 ? 0 : 1
        message[i] = message_bit
    end
    return(message)
end
=#

#get kth bit
function get_kth_bit(k, n)
    mask = 1 << k
    bit = (n & mask) >> k
    return bit
end

#memory saving matrix multiplication
function matrix_mult(h_hat, y)
    w = length(h_hat)
    h = ndigits(maximum(h_hat), base=2)
    block_num = div(size(y)[1],w)
    message = zeros(Int64, block_num)
    row_length = h*w
    row = [get_kth_bit(h-div(i-1,w)-1, h_hat[mod(i-1,w)+1]) for i in 1:row_length]
    for i in 1:h
        cropped_row = row[end-(i*w)+1:end]
        combined = cropped_row .& y[1:length(cropped_row)]
        ones = sum(combined)
        message_bit = mod(ones,2)
        message[i] = message_bit
    end
    for i in h+1:block_num
        mult_offset = (i-h)*w +1
        combined = row .& y[mult_offset:mult_offset+row_length-1]
        ones = sum(combined)
        message_bit = mod(ones,2)
        message[i] = message_bit
    end
    return(message)
end

#testing julia function calls
function test(number)
    y = number > 10 ? 1000.0 : 0.0
    return y
end
end 