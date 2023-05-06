using GR
using Suppressor
using LinearAlgebra
using Statistics
using Random
using Dates
using ArgParse
using Dates
using DataFrames
using JSON
using CSV
using Logging
using Test
using Random
using Suppressor
using LogicCircuits
using ProbabilisticCircuits
using LearnFairPSDD
using Combinatorics
using DataStructures
include("structures.jl")



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