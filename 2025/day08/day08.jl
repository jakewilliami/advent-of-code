# Today's problem was interesting.  We were given a list of coordinates in 3D
# space, representing junction boxes.  We need to join the junction boxes up
# to connect circuits, but because we are conscious of how much wire it might
# take to join them up, we want to start with the pairs of junction boxes that
# are closest to each other.
#
# This is exactly what we did in part 1: join the closest 1,000 pairs of junction
# boxes together into circuits.
#
# In part 2, we had to keep joining circuits by distance until you have one
# giant circuit; what was the last pair of junction boxes you connected?
#
# Despite the implementation having some nuances, the problem itself is really
# quite simple.  You can do what it says on the tin and that's efficient enough.
# I literally simulated all of this in the naïve sense; keeping track of which
# junction boxes are a part of which circuits, and joining them together.
#
# Despite this, it took me a while to solve part 2; I wasn't thinking very clearly
# and the code I wrote ended up being overly convoluted.  I am more happy with the
# cleaned up version, though.  And I used Julia's `something` function for the
# first time---even though I've known about it for years, it's never come up
# organically until now.
#
# Honourable mention: there's a really elegant solution that I don't understand
# using union find, written by JP: [1], [2]
#
# [1]: youtube.com/watch?v=Gd4-LOBfA88
# [2]: github.com/jonathanpaulson/AdventOfCode/blob/826497f7/2025/8.py#L21-L28

using LinearAlgebra


### Parse Input ###

const Index = CartesianIndex
const Circuit = Set{Index}

function parse_input(input_file::String)
    L = strip.(readlines(input_file))
    return Index[Index(parse.(Int, split(line, ','))...) for line in L]
end


### Part 1 ###

# I use this struct as an unordered pair.  However, the underlying data structure
# is a tuple for performance reasons.  To maintain the idea that a JunctionPair is
# unordered, we need to sort the underlying data.  That way, if an instance is used
# as a key, the underlying tuple will always have the same order no matter the
# order of insersion, and will therefore be equated the same whether you write
# JunctionPair(a, b) or JunctionPair(b, a); thereby, in practice, encoding an
# unordered pair of indices.
#
# I could have used a set instead of a tuple, but for performance on iteration,
# I did not, as sets would require collecting and sorting for each iteration.
# Better to handle that at instantiation and then efficiently iterate over
# the underlying tuple.
#
# The indices themselves (which make up the tuple) refer to points in space of
# "junction boxes;" a box that can have wires connected to it.
struct JunctionPair
    p::Tuple{Index, Index}

    JunctionPair(p::Tuple{Index, Index}) = new(sort(p))
end

JunctionPair(a::Index, b::Index) = JunctionPair((a, b))
Base.iterate(s::JunctionPair) = Base.iterate(s.p)
Base.iterate(s::JunctionPair, state) = Base.iterate(s.p, state)

# Compute Euclidean distance using LinearAlgebra
distance(i::Index, j::Index) = norm(Tuple(i - j))

# Find index of circuit to which index i belongs
find_circuit(circuits::Vector{Circuit}, i::Index) =
    findfirst(circuit -> i ∈ circuit, circuits)

# Precompute the stinctance between all pairs of junction boxes
function precompute_distances(data::Vector{Index})
    D = Dict{JunctionPair, Float64}()

    for i in 1:length(data)
        for j in i+1:length(data)
            a, b = data[i], data[j]
            d = distance(a, b)
            D[JunctionPair(a, b)] = d
        end
    end

    return D
end

# Construct an initial state circuit for the top 1,000 pairs of junction
# boxes who have the smallet distance from one another.  These pairs
# should be sorted by distance in the second argument of the function.
function init(data::Vector{Index}, sorted::Vector{JunctionPair})
    circuits = Circuit[]

    # Memoise the index of the circuit that a junction (pair of indices) exists
    mem = Dict{Union{JunctionPair, Index}, Int}()

    # Take the first 1,000 smallest circuits, which is the required initial
    # state for part 1
    for (i, j) in sorted[1:1000]
        kᵢ, kⱼ = find_circuit(circuits, i), find_circuit(circuits, j)

        # Base case: junction boxes i and j do not belong to a circuit yet,
        # so they can be paied as one.
        if isnothing(kᵢ) && isnothing(kⱼ)
            push!(circuits, Circuit((i, j)))
            continue
        end

        # Case 2: exactly one of i or j are already part of a circuit, so the
        # other can be added to it.
        if isnothing(kᵢ) + isnothing(kⱼ) == 1
            k = something(kᵢ, kⱼ)
            push!(circuits[k], i)
            push!(circuits[k], j)
            continue
        end

        # Case 3: both i and j exist in circuits, but they are not the same,
        # in which case we need to join the two circuits together
        @assert all(!isnothing, (kᵢ, kⱼ))
        if kᵢ != kⱼ
            union!(circuits[kᵢ], circuits[kⱼ])
            deleteat!(circuits, kⱼ)
            continue
        end

        # Default case: they can both be added to the same circuit; though
        # if they are already in the same circuit, then we should never
        # be processing them twice, so we could also skip this case
        @assert kᵢ == kⱼ
        push!(circuits[kᵢ], i)
        push!(circuits[kⱼ], j)
    end

    # Because we only handled the top 1,000 pairs of junction boxes, there
    # may be some remaining that are not in any circuit.  We can add them
    # to the list of circuits, as their own, singleton circuit, for
    # completeness
    for i in data
        any(i ∈ c for c in circuits) && continue
        push!(circuits, Circuit((i,)))
    end

    return circuits
end

function part1(data::Vector{Index}, sorted::Vector{JunctionPair})
    circuits = init(data, sorted)

    # Now that we have the initial circuits connected for the closest
    # 1,000 pairs of junction boxes, multiply together the size
    # of the largest three circuits to get our answer
    return prod(sort(map(length, circuits), rev=true)[1:3])
end


### Part 2 ###

# Given a list of circuits, find the first two circuits that are closest
# together, so that we can join them
function find_nearest_joinable_circuits(
    circuits::Vector{Circuit},
    sorted::Vector{JunctionPair},
)
    for p in sorted
        i, j = p
        kᵢ, kⱼ = find_circuit(circuits, i), find_circuit(circuits, j)
        @assert !isnothing(kᵢ) && !isnothing(kⱼ)
        kᵢ != kⱼ && return p, kᵢ, kⱼ
    end

    error("unreachable")
end

function join_nearest_two_circuits!(
    circuits::Vector{Circuit},
    sorted::Vector{JunctionPair},
)
    # Step 1: find the smallest distance between two junction boxes that
    # are not in the same circuit
    _, kᵢ, kⱼ = find_nearest_joinable_circuits(circuits, sorted)

    # Step 2: join them into the same circuit
    union!(circuits[kᵢ], circuits[kⱼ])
    deleteat!(circuits, kⱼ)

    return circuits
end

function part2(data::Vector{Index}, sorted::Vector{JunctionPair})
    # Initialise 1,000 pairs of junction boxes into circuits, as we did
    # for part 1.  This is a reasonable starting state.
    circuits = init(data, sorted)

    # Join circuits together until we have only two circuits remaining
    while length(circuits) > 2
        join_nearest_two_circuits!(circuits, sorted)
    end

    # Record the last pair that joins the whole circuit together,
    # and calculate the answer (the product of their x coordinates)
    (i, j), _, _ = find_nearest_joinable_circuits(circuits, sorted)
    return first(Tuple(i)) * first(Tuple(j))
end


### Main ###

function main()
    data = parse_input("data08.txt")

    # Pre-computed data for use downstream
    distances = precompute_distances(data)
    sorted = sort([(k, v) for (k, v) in distances], by = x -> last(x))
    sorted = JunctionPair[x for (x, _) in sorted]

    # Part 1
    part1_solution = part1(data, sorted)
    @assert part1_solution == 97384
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data, sorted)
    @assert part2_solution == 9003685096
    println("Part 2: $part2_solution")
end

main()
