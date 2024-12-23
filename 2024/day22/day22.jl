# Nice easy day today.  We were given a list of numbers which were the initial
# secrets for each monkey merchant in a market, and an algorithm for each monkey
# to calculate their next secret.  The secret has something to do with prices.
#
# Part 1 asked us to add together all monkeys' 2000th secret.  The only issue
# was that part 2 was a little confusing.  The cost of their bananas were the
# ones digits of the secret (or something like that), and they would look for
# a sequence of "four consecutive changes" in cost before selling.  We were to
# find the sequence such that we maximise the profit when all monkeys see the
# sequence of changes/deltas.
#
# My initial solution, whose time complexity was too high, would look for all
# possible sequences and calculate their scores over all monkeys.  Though,
# "four consecutive changes" apparently does not mean that we have to have a
# change in price.  It took 7 hours to run because I was asleep and didn't want
# to optimise it, and it was wrong because I was ignoring sequences with no
# change in them.  I also took some time debugging when I realised that actually
# they had changed the sample input for part 2.  Nevertheless, a pretty nice
# and simple day.

using DataStructures


### Parse Input ###

parse_input(input_file::String) =
    parse.(Int, strip.(readlines(input_file)))


### Part 1 ###

# mix x into n
mix(n::Int, x::Int) = n ⊻ x

# prune n
prune(n::Int) = return n % 16_777_216

function next_secret(n::Int)
    n = prune(mix(n, 64n))
    n = prune(mix(n, n ÷ 32))
    n = prune(mix(n, 2048n))
    return n
end

const N = 2000

function part1(data::Vector{Int})
    return sum(data) do n
        # Get Nth secret
        for _ in 1:N
            n = next_secret(n)
        end
        n
    end
end


### Part 2 ###

# Number of consecutive changes
const M = 4

function secrets(initial_secret::Int)
    s = initial_secret
    A = Vector{Int}(undef, N + 1)
    A[1] = s
    for i in 1:N
        s = next_secret(s)
        A[i + 1] = s
    end
    return A
end

cost_of_information(n::Int) = first(digits(next_secret(n)))

function secret_deltas(initial_secret::Int)
    s = initial_secret
    c = cost_of_information(initial_secret)
    A = Vector{Int}(undef, N)
    for i in 1:N
        s = next_secret(s)
        c′ = cost_of_information(s)
        A[i] = c′ - c
        c = c′
    end
    return A
end

function costs(initial_secret::Int)
    A = Vector{Int}(undef, N + 1)
    S = secrets(initial_secret)
    for i in 1:length(S)
        A[i] = cost_of_information(S[i])
    end
    return A
end

# Calculate all sequence scores from all initial secrets
function scores(initial_secrets::Vector{Int})
    scores = DefaultDict{NTuple{M, Int}, Int}(0)

    for initial_secret in initial_secrets
        these_costs = costs(initial_secret)[2:end]
        Δ = secret_deltas(initial_secret)
        seen = Set{NTuple{M, Int}}()
        for i in 1:length(Δ)-(M-1)
            δ = Tuple(Δ[i:i+M-1])

            # It's find *first*, so don't use score if it's already been used
            δ ∈ seen && continue
            push!(seen, δ)

            scores[δ] += these_costs[i+M-1]
        end
    end

    return scores
end

part2(data::Vector{Int}) = maximum(values(scores(data)))


### Main ###

function main()
    data = parse_input("data22.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 14869099597
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 1717
    println("Part 2: $part2_solution")
end

main()
