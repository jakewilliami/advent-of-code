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
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function find_start(M)
    for i in CartesianIndices(M)
        if M[i] == 'S'
            return i
        end
    end
end

const Index = CartesianIndex{2}

function render(M, V)
    M = deepcopy(M)
    io = IOBuffer()
    D = Dict{Index, Char}(INDEX_UP => '^', INDEX_DOWN => 'v', INDEX_LEFT => '<', INDEX_RIGHT => '>')
    for (i, d) in V
        if M[i] ∉ "SE"
            M[i] = D[d]
        end
    end
    for row in eachrow(M)
        println(io, join(row))
    end
    println(String(take!(io)))
end

function part1a(M)
    i = find_start(M)
    d = INDEX_EAST

    # T = Tuple{Index, Direction, Int, Set{Tuple{Index, Direction}}, Vector{Tuple{Index, Direction}}}
    # T = Tuple{Index, Direction, Int, Set{Tuple{Index, Direction}}}
    T = Tuple{Index, Direction, Int}
    Q = Queue{T}()
    S = Set{Tuple{Index, Direction}}()
    enqueue!(Q, (i, d, 0))#, Set{Tuple{Index, Direction}}())) # Tuple{Index, Direction}[]
    score = typemax(Int)
    V = []

    while !isempty(Q)
        i, d, s = dequeue!(Q)

        if hasindex(M, i) && M[i] == 'E'
            if s < score
                score = s
                # V = P
            end
            continue
        end

        if (i, d) ∈ S
            continue
        end
        push!(S, (i, d))
        # push!(P, (i, d))

        for (j, d′, s′) in ((i + d, d, 1), (i, rotr90(d), 1000), (i, rotl90(d), 1000))
            if hasindex(M, j) && M[j] != '#'
                enqueue!(Q, (j, d′, s + s′))#, deepcopy(S)))#, deepcopy(P)))
            end
        end
    end

    render(M, V)

    score
end

using Graphs
import Graphs: SimpleGraphs.SimpleEdge

# part 1 binary heap idea from https://github.com/jonathanpaulson/AdventOfCode/blob/46c09b4ddd0eb0ad0625a645a099af57c36410e1/2024/16.py
function part1(M)
    i = find_start(M)
    d = INDEX_EAST
    # Q = Queue{Tuple{Int, Index, Direction}}()
    Q = MutableBinaryHeap(Base.By(last), Tuple{Index, Direction{2}, Int}[])
    push!(Q, (i, d, 0))

    dist = Dict()
    S = Set{Tuple{Index, Direction}}()
    best = typemax(Int)

    while !isempty(Q)
        i, d, s = pop!(Q)
        if !haskey(dist, (i, d))
            dist[(i, d)] = s
        end
        if M[i] == 'E' && s < best
            best = s
        end
        if (i, d) ∈ S
            continue
        end
        push!(S, (i, d))
        j = i + d
        if hasindex(M, j) && M[j] != '#'
            push!(Q, (j, d, s + 1))
        end
        push!(Q, (i, rotr90(d), s + 1000))
        push!(Q, (i, rotl90(d), s + 100))
    end
    best
end

function p1dist(M)
    i = find_start(M)
    d = INDEX_EAST
    # Q = Queue{Tuple{Int, Index, Direction}}()
    Q = MutableBinaryHeap(Base.By(last), Tuple{Index, Index, Int}[])
    push!(Q, (i, d, 0))

    dist = Dict()
    S = Set{Tuple{Index, Direction}}()
    best = typemax(Int)

    while !isempty(Q)
        i, d, s = pop!(Q)
        if !haskey(dist, (i, d))
            dist[(i, d)] = s
        end
        if M[i] == 'E' && s < best
            best = s
        end
        if (i, d) ∈ S
            continue
        end
        push!(S, (i, d))
        j = i + d
        if hasindex(M, j) && M[j] != '#'
            push!(Q, (j, d, s + 1))
        end
        push!(Q, (i, rotr90(d), s + 1000))
        push!(Q, (i, rotl90(d), s + 100))
    end
    dist, best
end

function find_end(M)
    for i in CartesianIndices(M)
        if M[i] == 'E'
            return i
        end
    end
end

function part2a(M)
    i = find_end(M)
    # Q = Queue{Tuple{Int, Index, Direction}}()
    Q = MutableBinaryHeap(Base.By(last), Tuple{Index, Index, Int}[])
    S = Set{Tuple{Index, Direction}}()
    for d in cardinal_directions(2)
        push!(Q, (i, d, 0))
    end
    dist = Dict()
    while !isempty(Q)
        i, d, s = pop!(Q)
        if !haskey(dist, (i, d))
            dist[(i, d)] = s
        end
        if (i, d) ∈ S
            continue
        end
        push!(S, (i, d))
        # going backwards instead of forwards here
        d′ = rot180(d)
        j = i + d′
        if hasindex(M, j) && M[j] != '#'
            push!(Q, (j, d′, s + 1))
        end
        push!(Q, (i, rotr90(d), s + 1000))
        push!(Q, (i, rotl90(d), s + 1000))
    end

    dist1, best = p1dist(M)
    println(best)
    P = Set{Index}()
    for i in CartesianIndices(M)
        for d in cardinal_directions(2)
            # (i, d) is on an optimal path if the distance from the start to end equals the distance from the start to (i, d) plus the distance from (i, d) to end
            t = (i, d)
            haskey(dist1, t) || continue
            haskey(dist, t) || continue
            if (dist1[t] + dist[t]) == best
                push!(P, i)
            end
         end
    end

    length(P)
end

# part 2 seen matrix idea from https://github.com/michel-kraemer/adventofcode-rust/blob/0300ade92131e605a7f38f34b8a9372555ebb508/2024/day16/src/main.rs/https://www.reddit.com/r/adventofcode/comments/1hfboft/comment/m2auven/
function part2(M)
    i = find_start(M)
    d = INDEX_EAST
    Q = MutableBinaryHeap(Base.By(last), Tuple{Index, Direction{2}, Vector{Index}, Int}[])
    push!(Q, (i, d, [], 0))

    # dist = Dict()
    # S = Set{Tuple{Index, Direction}}()
    best = typemax(Int)

    # a mapping of seen places and their lowest score
    seen = fill(typemax(Int) - 1000, size(M))

    # BS = Set{Int}()
    BP = Set{Index}()

    while !isempty(Q)
        i, d, P, s = pop!(Q)

        if M[i] == 'E' && s ≤ best
            # if s > best
                # This path is worse than any best path we've found before, and
                # not other path from here will be any good
                # break
            # end

            best = s

            for p in P
                push!(BP, p)
            end
        end

        for d′ in cardinal_directions(2)
            j = i + d′
            s′ = s
            if d == origin(2) || d == d′
                s′ += 1
            else
                s′ += 1000
            end

            # let last_seen_score = seen[ny as usize * width + nx as usize];
            last_seen_score = seen[j]

            prev_dy, prev_dx = Tuple(d)
            dy, dx = Tuple(d′)
            if hasindex(M, j) && M[j] != '#' &&
                # don't go back
                !(prev_dx == 0 && prev_dy == -dy) &&
                !(prev_dx == -dx && prev_dy == 0) &&
                #  we might have stepped on a path where we were just about to turn
                # just continue and see how it goes
                s′ ≤ (last_seen_score + 1000)

                seen[j] = s′
                push!(Q, (j, d′, push!(deepcopy(P), j), s′))
            end
        end

        #=if (i, d) ∈ S
            continue
        end
        push!(S, (i, d))
        j = i + d
        if hasindex(M, j) && M[j] != '#'
            push!(Q, (j, d, push!(deepcopy(P), j), s + 1))
        end
        push!(Q, (i, rotr90(d), push!(deepcopy(P), i), s + 1000))
        push!(Q, (i, rotl90(d), push!(deepcopy(P), i), s + 100))=#
    end
    return length(BP) + 1  # including the start
end

function main()
    data = parse_input("data16.txt")
    # data = parse_input("data16.test.txt")
    # data = parse_input("data16.test2.txt")

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

# NOT 97432

# p2
# NOT 461, too low
# NOT 587, too high
# NOT 435
