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

export get_query

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


function get_query(test_x1::FairDataset) 
    sample_frac = 0.1
    n_rows = nrow(test_x1.data)
    # randomly select rows without replacement
    rows_idx = randperm(n_rows)[1:50]

    # select the rows from the DataFrame
    sample_df = test_x1.data[rows_idx, :]

    data_mat = Matrix(sample_df)
    outdir = "/Users/sauravanchlia/Fair_ML/PRL/prod/FairPC.jl/analysis/data/latent_variable"
    list_of_dfs = Vector{DataFrame}()

    for k in [3,4,5]
        res = create_dataframe(data_mat[1,1:7],k)
        res[!,:x8] = fill(data_mat[1,8:8][1], size(res,1))
        for i in 2:size(data_mat, 1)
            inst = data_mat[i,1:7]
            perms = create_dataframe(inst,k)
            perms[!,:x8] = fill(data_mat[1,8:8][1], size(perms,1))
            res = vcat(res,perms)
        end
        push!(list_of_dfs, res)
        CSV.write(joinpath(outdir, "$(k)_test.csv"), res)
    end
    list_of_dfs
end

# k_3, k_4, k_5 = get_query(train_x1)



function predict_all_se(T, result_circuits, log_opts, train_x, test_x, flag)
    for (key, value) in result_circuits
        dir = joinpath(log_opts["outdir"], key)
        (pc, vtree) = value
        if !isdir(dir)
            mkpath(dir)
        end
        run_fairpc = T(pc, vtree, train_x.S, train_x.D)
        predition_bottom(run_fairpc,test_x,flag)
    end
end


function predition_bottom(fairpc::StructType, fairdata, flag)
    @inline get_node_id(id::⋁NodeIds) = id.node_id
    @inline get_node_id(id::⋀NodeIds) = @assert false
    results = Dict()
    data = fairdata

    actual_label = copy(fairdata[!,:x8])
    sensitive_label = data[:, :x4]
    data = reset_end_missing(data)
    _, flows, node2id = marginal_flows(fairpc.pc, data)
    D = get_node_id(node2id[node_D(fairpc)])
    n_D = get_node_id(node2id[node_not_D(fairpc)])
    P_D = exp.(flows[:, D])
    # @assert all(flows[:, D] .<= 0.0)
    @assert all(P_D .+ exp.(flows[:, n_D]) .≈ 1.0)
    P_D = min.(1.0, P_D)
    # P(D|E), 
    results["P(D|e)"] = P_D
    results["D"] = Int8.(actual_label)
    results["S"] = Int8.(sensitive_label)
    CSV.write("$(flag)_csv", results)

end