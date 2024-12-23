using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))

    # the puzzle input is the initial secret number of each buyer
    L = strip.(readlines(input_file))
    return parse.(Int, L)
    # L = get_integers.(L)
    return L
end

# mix x into n
function mix(n, x)
    #=
    To mix a value into the secret number, calculate the bitwise XOR of the given value and the secret number. Then, the secret number becomes the result of that operation. (If the secret number is 42 and you were to mix 15 into the secret number, the secret number would become 37.)
    =#
    return n ⊻ x  # n becomes this
end

# prune n
function prune(n)
    #=
    To prune the secret number, calculate the value of the secret number modulo 16777216. Then, the secret number becomes the result of that operation. (If the secret number is 100000000 and you were to prune the secret number, the secret number would become 16113920.)
    =#
    return n % 16_777_216  # n becomes thid
end

function next_secret(n)
    #=
    1. Calculate the result of multiplying the secret number by 64. Then, mix this result into the secret number. Finally, prune the secret number.
    2. Calculate the result of dividing the secret number by 32. Round the result down to the nearest integer. Then, mix this result into the secret number. Finally, prune the secret number.
    3. Calculate the result of multiplying the secret number by 2048. Then, mix this result into the secret number. Finally, prune the secret number.
    =#

    n = prune(mix(n, 64n))
    n = prune(mix(n, n ÷ 32))
    n = prune(mix(n, 2048n))
    return n
end

function get_nth_secret(initial_secret, n)
    s = initial_secret
    for _ in 1:n
        s = next_secret(s)
    end
    return s
end

function part1(data)
    return sum(data) do n
        get_nth_secret(n, 2000)
    end
end

function n_secrets(initial_secret::Int, n::Int)
    s = initial_secret
    A = Vector{Int}()
    sizehint!(A, n + 1)
    push!(A, s)
    for _ in 1:n
        s = next_secret(s)
        push!(A, s)
    end
    A
end

function cost_of_information(n)
    return first(digits(next_secret(n)))
end

mutable struct Secret
    curr::Int
    cost::Int
end

function Secret(curr::Int)
    Secret(curr, cost_of_information(curr))
end
function next!(s::Secret)
    s.curr = next_secret(s.curr)
    s.cost = cost_of_information(s.curr)
    s
end

const N = 2000
const M = 4

function n_secret_deltas(initial_secret)
    s = initial_secret
    c = cost_of_information(initial_secret)
    A = Vector{Int}()
    sizehint!(A, N)
    for _ in 1:N
        s = next_secret(s)
        c′ = cost_of_information(s)
        push!(A, c′ - c)
        c = c′
    end
    A
end

function find_possible_sequences(initial_secrets)
    S = Set{NTuple{4, Int}}()
    println("  finding possible sequences...")
    for (j, initial_secret) in enumerate(initial_secrets)
        if j % 200 == 0 || j == 1
            println("    $j/$(length(initial_secrets))")
        end
        Δ = n_secret_deltas(initial_secret)
        for i in 1:length(Δ)-M+1
            t = Tuple(Δ[i:i+M-1])
            @assert length(t) == M
            # println(t)

            # must be consecutive changes
            #=is_consecutive = true
            for k in 2:length(t)
                if t[k] == t[k - 1]
                    is_consecutive = false
                end
            end
            # println(t)
            is_consecutive || continue
            # println(t)=#

            # changes need to be consecutive
            all(!iszero, t) || continue
            if t == (-2, 1, -1, 3) # t == (-9, -9, -1, 0)
                # println("'maximal'")
                # println(is_consecutive)
            end

            push!(S, t)
        end
    end
    # @assert (-2,1,-1,3 ) ∈ S
    S
end

function i_dont_know_why_i_wrote_this_function(initial_secret)
    A = Vector{Int}()
    sizehint!(A, N)
    S = n_secrets(initial_secret, N)
    for i in 2:length(S)
        push!(A, S[i] - S[i - 1])
    end
    A
end

function n_costs(initial_secret)
    A = Vector{Int}()
    sizehint!(A, N + 1)
    S = n_secrets(initial_secret, N)
    for i in 1:length(S)
        push!(A, cost_of_information(S[i]))
    end
    A
end

function evaluate_sequence_profit(initial_secret::Int, sequence::NTuple{M, Int})
    @assert length(sequence) == M
    profit = 0
    costs = n_costs(initial_secret)[2:end]
    Δ = n_secret_deltas(initial_secret)
    @assert length(costs) == length(Δ) == N "length(costs)=$(length(costs)), length(Δ)=$(length(Δ))"

    for i in 1:length(Δ)-(M-1)
        δ = Tuple(Δ[i:i+M-1])
        @assert length(δ) == M
        if δ == sequence
            if δ == sequence == (-2, 1, -1, 3)
                println("[init=$(initial_secret)] costs[i+M-0]=$(costs[i+M-0]), costs[i+M-1]=$(costs[i+M-1]), costs[i+M-2]=$(costs[i+M-2]), costs[i+M-3]=$(costs[i+M-3]), costs[i+M-M]=$(costs[i+M-M])=costs[i]=$(costs[i])")
            end
            return costs[i+M-1]
        end
    end

    if sequence == (-2, 1, -1, 3)
        println("[init=$(initial_secret)] no sequence $(sequence) found")
    end

    return 0
end

# too slow---and somehow wrong on real data but not test data
function find_maximal_sequence(initial_secrets)
    sequences = find_possible_sequences(initial_secrets)
    best_sequence = nothing
    best_profit = 0
    for (i, sequence) in enumerate(sequences)
        # println("      $i/$(length(sequences))")
        if i % 500 == 0 || i == 1
            println("  $i/$(length(sequences))")
        end
        profit = sum(initial_secrets) do initial_secret
            evaluate_sequence_profit(initial_secret, sequence)
        end

        if sequence == (-2, 1, -1, 3)
            println(initial_secrets)
            # println("profit with sequence $sequence: $profit")
        end
        # println("profit with sequence $sequence: $profit")

        if best_profit < profit
            best_sequence = sequence
            best_profit = profit
        end
    end
    best_sequence
end

function get_scores(initial_secrets)
    scores = DefaultDict{NTuple{M, Int}, Int}(0)
    # scores = Dict{NTuple{M, Int}, Int}()
    for initial_secret in initial_secrets
        costs = n_costs(initial_secret)[2:end]
        Δ = n_secret_deltas(initial_secret)
        seen = Set{NTuple{M, Int}}()
        for i in 1:length(Δ)-(M-1)
            δ = Tuple(Δ[i:i+M-1])
            # it's findfirst
            if δ ∈ seen
                continue
            end
            push!(seen, δ)
            # don't changes need to be consecutive?  but i get the wrong answer if they are
            # all(!iszero, δ) || continue
            if δ == (-2, 2, -1, -1)
                # println("[init=$(initial_secret)] costs[i+M-0]=$(costs[i+M-0]), costs[i+M-1]=$(costs[i+M-1]), costs[i+M-2]=$(costs[i+M-2]), costs[i+M-3]=$(costs[i+M-3]), costs[i+M-M]=$(costs[i+M-M])=costs[i]=$(costs[i])")
            end
            scores[δ] += costs[i+M-1]
        end
    end
    return scores
end

function part2(data)
    return findmax(get_scores(data))
    return maximum(values(get_scores(data)))
    # println(n_secret_deltas(2))
    # return 0
    println("finding maximal sequence...")
    sequence = find_maximal_sequence(data)
    println("maximal sequence found: $sequence -> $(Tuple(evaluate_sequence_profit(n, sequence) for n in data))")
    println("calculating end profit...")
    return sum(enumerate(data)) do (i, n)
        if i % 200 == 0 || i == 1
            println("  $i/$(length(data))")
        end
        evaluate_sequence_profit(n, sequence)
    end
    return length(find_possible_sequences(data))
    return sum(data) do n
        # get_nth_secret2(n, 2000)
        # n′ = first(digits(123))
    end
end

function main()
    data = parse_input("data22.txt")
    # data = parse_input("data22.test.txt")
    # damn, I didn't realise they'd changed the test input
    # data = parse_input("data22.test2.txt")

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()

#=
# Too low
Part 2: 1676

real    416m19.660s
user    366m51.379s
sys 50m14.840s
=#
