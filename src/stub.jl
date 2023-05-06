using PyCall
using DataStructures
using DataFrames
using CSV
using LogicCircuits
using ProbabilisticCircuits
using Combinatorics
using Random
include("structures.jl")
include("data.jl")


function create_dataframe(inst::Array{Bool, 1}, k::Int)
    n = length(inst)
    m = binomial(n, k)
    indices = collect(combinations(1:n, k))
    data = Matrix{Union{Missing, Bool}}(missing, m, n)
    for i in 1:m
        for j in indices[i]
            data[i, j] = inst[j]
        end
    end
    return DataFrame(data, :auto)
end

name = "compas"
struct_type = "FairPC"
T = STRUCT_STR2TYPE[struct_type]
SV = "Sex_"
fold = 1
num_X = 10
train_x, valid_x, test_x = load_data(name, T, SV; fold=fold, num_X=num_X)
train_x1, valid_x1, test_x1 = convert2nonlatent(train_x, valid_x, test_x)

sample_frac = 0.1
n_rows = nrow(test_x1.data)
n_samples = 50
# randomly select rows without replacement
rows_idx = randperm(n_rows)[1:n_samples]

# select the rows from the DataFrame
sample_df = test_x1.data[rows_idx, :]
# println(filter(row -> row.x4 ∈ [1], sample_df))
# println(filter(row -> row.x4 ∈ [0], sample_df))

label = select(sample_df, 8:8)
data_mat = Matrix(select(sample_df, 1:(size(sample_df, 2)-1)))
println(data_mat)

outdir = "/Users/harshit/Documents/GitHub/PRLProj/analysis/data/latent_variable"
for k in [3,4,5]
    res = create_dataframe(data_mat[1,:],k)
    label_tmp = DataFrame(x8 = fill(label[1,1][1], size(res,1)))
    res = hcat(res, label_tmp)
    for i in 2:size(data_mat, 1)
        inst = data_mat[i,:]
        temp = create_dataframe(inst,k)
        label_tmp = DataFrame(x8 = fill(label[i,1][1], size(temp,1)))
        temp = hcat(temp, label_tmp)
        res = vcat(res, temp)
    end
    CSV.write(joinpath(outdir, "$(k)_test.csv"), res)
end