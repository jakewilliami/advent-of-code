using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

const Index = CartesianIndex{2}

function find_start(M)
    for i in CartesianIndices(M)
        M[i] == 'S' && return i
    end
end

function find_end(M)
    for i in CartesianIndices(M)
        M[i] == 'E' && return i
    end
end

function find_start_direction(M, si)
    D = Direction{2}[]
    for d in cardinal_directions(2)
        j = si + d
        if hasindex(M, j) && M[j] != '#'
            push!(D, d)
        end
    end
    return only(D)
end

distances = Dict()

function find_path(M, si, ei)
    Q = Queue{Tuple{Index, Int, Vector{Index}}}()
    S = Set{Index}()

    enqueue!(Q, (si, 0, [si]))

    while !isempty(Q)
        i, s, p = dequeue!(Q)

        if i == ei
            distances[i] = s
            # we need to reverse these so that instead of measuring distance from the start it measures distance from the end
            for (k, v) in distances
                distances[k] = s - v
            end
            @assert distances[si] == s "distances[src] = $(distances[si]) ≠ $s = s"
            return p
        end

        if i ∈ S
            continue
        end
        push!(S, i)

        distances[i] = s

        # @assert isone(sum(hasindex(M, i + d) && M[i + d] != '#' for d in cardinal_directions(2)))

        for d in cardinal_directions(2)
            j = i + d
            if hasindex(M, j) && M[j] != '#'
                enqueue!(Q, (j, s + 1, vcat(p, j)))
            end
        end
    end
end

struct Cheat1
    start_index::Int
    end_index::Int
    start_pos::Index
    end_pos::Index
end

Base.hash(c::Cheat1) = hash((c.start_pos, c.end_pos))

function find_cheats1(M, P, sc)
    C = Cheat[]
    ec = sc + 2
    i = P[sc + 1]
    for d in cardinal_directions(2)
        j = i + d
        hasindex(M, j) || continue
        for d2 in cardinal_directions(2)
            k = j + d2
            k == i && continue  # don't just go backwards
            hasindex(M, k) || continue
            M[k] != '#' || continue
            push!(C, Cheat(sc, ec, j, k))
        end
    end
    C
end

function solve1(M, si, ei)
    # index, move number, cheat
    Q = Queue{Tuple{Index, Int, Cheat}}()
    S = Set{Tuple{Index, Index, Index}}()

    # Initialise queue with cheat options
    P = find_path(M, si, ei)
    N = length(P)
    C = Set{Tuple{Index, Index}}()
    for i in 0:(N-2)
        # for each possible start cheat index, there may be multiple possible cheats
        for c in find_cheats(M, P, i)
            if (c.start_pos, c.end_pos) ∉ C
                push!(C, (c.start_pos, c.end_pos))
                enqueue!(Q, (si, 0, c))
            end
        end
    end

    # confirm no duplictes
    #=for i in 1:length(C)
        for j in (i+1):length(C)
            @assert (C[i].start_pos, C[i].end_pos) != (C[j].start_pos, C[j].end_pos)
        end
    end=#

    disqualified = Set{Tuple{Int, Int}}()
    finished = Set{Tuple{Int, Int}}()

    A = Dict{Cheat, Int}()
    while !isempty(Q)
        # println(length(Q))
        i, s, c = dequeue!(Q)
        # println("i=$i, s=$s, sc=$sc, ec=$ec")

        # if (sc, ec) ∈ disqualified
            # continue
        # end

        # "segfault"
        # if M[i] == '#' && s ∉ (sc + 1, ec)
        # if M[i] == '#' && !(sc < s <= ec)
            # push!(disqualified, (sc, ec))
            # continue
        # end

        if (i, c.start_pos, c.end_pos) ∈ S
            continue
        end
        push!(S, (i, c.start_pos, c.end_pos))

        if (c.start_index, c.end_index) == (20, 20+2)
            println(i, ", ", s)
        end

        if i == ei
            # if s == (62-100)*-1
            # println("found path: i=$i, s=$s, sc=$sc, ec=$ec")
            # end
            @assert !haskey(A, c)
            if haskey(A, c)
                A[c] = min(s, A[c])
            else
                A[c] = s
            end
            # if (sc, ec) ∉ finished
                if (c.start_index, c.end_index) == (20, 20+2)
                    println("found path: i=$i, s=$s, c=$c, savings=$(N-s)")
                end
            # @assert (sc, ec) ∉ finished
                # push!(A, s)
                # push!(finished, (sc, ec))
            # end
        end

        for d in cardinal_directions(2)
            if i == CartesianIndex(8, 12) && (c.start_index, c.end_index) == (20,20+2)
                println("trying d=$d ($(i + d))")
            end
            j = i + d
            if hasindex(M, j)
                s′ = s + 1
                # can only go through walls if in the next move cheating is allowed
                if M[j] != '#' || s == c.start_index
                    if i == CartesianIndex(8, 12) && (c.start_index, c.end_index) == (20,20+2)
                        println("queueing!")
                    end
                    enqueue!(Q, (j, s′, c))
                end
            end
        end
    end

    # println("shortest path: ", N - A[(20,20+2)])

    # println([(N - s, s) for s in A])
    savings = [N - s for s in values(A)]
    D = countmap(savings)
    haskey(D, 0) && pop!(D, 0)
    map(println, sort(collect(D), by = x -> x[1], rev = true))
    return
    N = 0
    for (s, n) in D
        if s ≥ 100
            N += n
        end
    end
    return N
end

struct Cheat
    start::Index
    stop::Index
end

Base.hash(c::Cheat) = hash((c.start, c.stop))

function find_cheats(M, i)
    C = Set{Cheat}()
    for d1 in cardinal_directions(2)
        j = i + d1
        hasindex(M, j) || continue
        for d2 in cardinal_directions(2)
            k = j + d2
            k == i && continue  # don't just go backwards
            hasindex(M, k) || continue
            M[k] != '#' || continue
            push!(C, Cheat(j, k))
        end
    end
    C
end

function solve(M, si, ei)
    # index, move number, cheat
    Q = Queue{Tuple{Index, Int, Cheat}}()
    S = Set{Tuple{Index, Cheat}}()

    # Initialise queue with cheat options
    P = find_path(M, si, ei)
    N = length(P)
    C = Set{Cheat}()
    for p in P
        # for each possible start cheat index, there may be multiple possible cheats
        for c in find_cheats(M, p)
            if c ∉ C
                push!(C, c)
                enqueue!(Q, (si, 1, c))
            end
        end
    end

    A = Dict{Cheat, Int}()
    while !isempty(Q)
        i, s, c = dequeue!(Q)

        if (i, c) ∈ S
            continue
        end
        push!(S, (i, c))

        if i == ei
            A[c] = s
        end

        if i == c.start
            enqueue!(Q, (c.stop, s + 1, c))
        else
            for d in cardinal_directions(2)
                j = i + d
                if hasindex(M, j)
                    # can only go through walls if in the next move cheating is allowed
                    if M[j] != '#' || j == c.start
                        enqueue!(Q, (j, s + 1, c))
                    end
                end
            end
        end
    end

    # println("shortest path: ", N - A[Cheat(Index(8, 11), Index(8, 12))])

    # println([(N - s, s) for s in A])
    savings = [N - s for s in values(A)]
    D = countmap(savings)
    # haskey(D, 0) && pop!(D, 0)
    # map(println, sort(collect(D), by = x -> x[1], rev = true))
    # return
    sum(D) do (s, n)
        s ≥ 100 ? n : 0
    end
end

function part1(data)
    si, ei = find_start(data), find_end(data)
    # this is very slow
    solve(data, si, ei)
end

function part2(data)
    si, ei = find_start(data), find_end(data)
    # this is very slow
    solve(data, si, ei)
end

function main()
    data = parse_input("data20.txt")
    # data = parse_input("data20.test.txt")

    # Part 1
    # part1_solution = part1(data)
    # @assert part1_solution ==
    # println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()

# NOT 1251
#=
time julia --project day20.jl
Part 1: 1429
Part 2: nothing

real    12m42.782s
user    3m25.529s
sys 7m36.958s
=#

#=
time julia --project day20.jl
/bin/bash: line 1:  4673 Killed: 9               julia --project day20.jl

real    211m11.932s
user    11m33.931s
sys 83m12.558s

Compilation exited abnormally with code 137 at Sat Dec 21 11:29:57
=#
