using CSV, DataFrames

const datafile = joinpath(@__DIR__, "inputs", "data01.csv")

function naive2(df)
    for i in eachrow(df)
        for j in eachrow(df)
            if i.n + j.n == 2020
                return i.n, j.n, i.n * j.n
            end
        end
    end
end



res1 = naive2(CSV.read(datafile, DataFrame))
@assert res1 == (833, 1187, 988771)
println(res1)

#=
BenchmarkTools.Trial:
  memory estimate:  306.53 KiB
  allocs estimate:  18724
  --------------
  minimum time:     1.230 ms (0.00% GC)
  median time:      1.414 ms (0.00% GC)
  mean time:        1.614 ms (0.78% GC)
  maximum time:     18.210 ms (0.00% GC)
  --------------
  samples:          3081
  evals/sample:     1
=#

function naive3(df)
    for i in eachrow(df)
        for j in eachrow(df)
            for k in eachrow(df)
                if i.n + j.n + k.n == 2020
                    return i.n, j.n, k.n, i.n * j.n * k.n
                end
            end
        end
    end
end

res2 = naive3(CSV.read(datafile, DataFrame))
@assert res2 == (1237, 511, 272, 171933104)
println(res2)

#=
BenchmarkTools.Trial:
  memory estimate:  289.41 MiB
  allocs estimate:  18966025
  --------------
  minimum time:     1.366 s (0.46% GC)
  median time:      1.408 s (0.48% GC)
  mean time:        1.425 s (0.47% GC)
  maximum time:     1.519 s (0.42% GC)
  --------------
  samples:          4
  evals/sample:     1
=#
