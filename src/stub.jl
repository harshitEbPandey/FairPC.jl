using PyCall
using DataStructures
using DataFrames
using CSV
using LogicCircuits
using ProbabilisticCircuits
using Combinatorics
include("structures.jl")
include("data.jl")


function create_dataframe(inst::Array{Bool, 1}, k::Int)
    n = length(inst)
    # println("N is $n")
    m = binomial(n, k)
    # println("M is $m")
    indices = collect(combinations(1:n, k))
    data = Matrix{Union{Missing, Bool}}(missing, m, n)
    for i in 1:m
        # println("Here:")
        for j in indices[i]
            data[i, j] = inst[j]
        end
        # print("Data $data")
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
# println("Working $train_x1")
using Random

sample_frac = 0.1
n_rows = nrow(test_x1.data)
# randomly select rows without replacement
rows_idx = randperm(n_rows)[1:50]

# select the rows from the DataFrame
sample_df = test_x1.data[rows_idx, :]
println("samples est")
println(filter(row -> row.x4 ∈ [1], sample_df))
println(filter(row -> row.x4 ∈ [0], sample_df))

data_mat = Matrix(sample_df)
outdir = "/Users/sauravanchlia/Fair_ML/PRL/prod/FairPC.jl/analysis/data/latent_variable"
for k in [3,4,5]
    res = create_dataframe(data_mat[1,1:7],k)
    for i in 2:size(data_mat, 1)
        inst = data_mat[i,1:7]
        print(inst)
        temp = create_dataframe(inst,k)
        temp[!,:x8] =  data_mat[i,8:8]
        vcat(res, create_dataframe(inst,k))
    end
    CSV.write(joinpath(outdir, "$(k)_test.csv"), res)
end
hcat(res, data_mat[!, 8:8])