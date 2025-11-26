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

struct Cheat2
    start::Index
    stop::Index
    len::Int
end

# find all indices that have a walking distance of n or less from si
function find_indices_in_n_of_i(M, si, n)
    Q = Queue{Tuple{Index, Int}}()
    # S = Set{Tuple{Index, Int}}()
    S = Set{Index}()
    A = Set{Tuple{Index, Int}}()
    enqueue!(Q, (si, 0))
    while !isempty(Q)
        i, s = dequeue!(Q)
        s ≤ n || continue

        # (i, s) ∈ S && continue
        # push!(S, (i, s))
        i ∈ S && continue
        push!(S, i)
        # bizzare bug here where i discounted some by returning seen rather than some answer
        push!(A, (i, s))

        for d in cardinal_directions(2)
            j = i + d
            hasindex(M, j) || continue
            enqueue!(Q, (j, s + 1))
        end
    end
    # delete!(S, (si, 0))
    A
end

# we can essentially teleport/wormhole if we know there's a valid path where the end is not a wall
function find_cheats2(M, si, P)
    @assert si ∈ P
    C = Set{Cheat2}()
    for (i, n) in find_indices_in_n_of_i(M, si, 20)
        hasindex(M, i) || continue
        M[i] != '#' || continue
        # make sure end is in the path somewhere
        i ∈ P || continue
        # make sure end is in the path after the start
        j, k = findfirst(==(si), P), findfirst(==(i), P)
        @assert !isnothing(j)
        @assert !isnothing(k)
        j < k || continue
        push!(C, Cheat2(si, i, n))
    end
    return C
end

function solve2(M, si, ei)
    # index, move number, cheat, cheat count
    Q = Queue{Tuple{Index, Int, Cheat2}}()
    S = Set{Tuple{Index, Index, Index}}()
    S′ = Set{Index}()
    save = 100
    println("collecting cheat paths")

    # Initialise queue with cheat options
    P = find_path(M, si, ei)
    N = length(P)
    C = Set()
    for p in P
        for c in find_cheats2(M, p, P)
            if (c.start, c.stop) ∉ C
                enqueue!(Q, (si, 1, c))
                push!(C, (c.start, c.stop))
            end
        end
    end
    println("found $(length(C)) cheats from $(N) path")
    println("solving while saving $save on grid $(size(M))")

    # A = Dict{Cheat, Int}()
    A = []
    iterations = 0
    while !isempty(Q)
        # log iterations
        if (iterations % 50_000_000) == 0
            println("queue length =", length(Q))
            iterations = 0
        end
        iterations += 1

        i, s, c = dequeue!(Q)

        # s < N - save || continue
        # s >= N - save && continue

        # avoid visiting the same state
        if (i, c.start, c.stop) ∈ S
            continue
        end
        push!(S, (i, c.start, c.stop))
        # if i ∈ S′
            # continue
        # end
        # push!(S′, i)

        # found an answer
        if i == ei
            # A[Cheat(c.start, c.stop)] = s
            # s <= N - save || continue
            push!(A, s)
        end

        # only explore cheats that save time
        # s ≤ N - save || continue
        if i == c.stop
            # distances[i] <= N - save - (s - c.len) || continue
            dist_to_finish = N - distances[i]
            time_saved = distances[i] - s
            # time_saved >= save || continue

        end
        # s ≤ N - save
         # ≥ save || continue

        #=for d in cardinal_directions(2)
            j = i + d
            hasindex(M, j) || continue
            if j == c.start
                enqueue!(Q, (c.stop, s + c.len + 1, c))
            end
            if M[j] != '#'
                enqueue!(Q, (j, s + 1, c))
            end
        end=#

        # If we are at the start of a cheat, one option is to go down that route
        if i == c.start
            # only explore cheats that save time
            new_path_time = s + c.len - 1 + distances[c.stop]
            if new_path_time ≥ (N - 100)
                enqueue!(Q, (c.stop, s + c.len, c))
            end
        end

        # Alternatively, look for other paths to take
        for d in cardinal_directions(2)
            j = i + d
            if hasindex(M, j) && M[j] != '#'
                enqueue!(Q, (j, s + 1, c))
            end
        end
    end

    # println("shortest path: ", N - A[Cheat(Index(8, 11), Index(8, 12))])

    # println([(N - s, s) for s in A])
    # savings = [N - s for s in values(A) if (N - s) ≥ 50]
    savings = [N - s for s in A if (N - s) ≥ save]
    D = countmap(savings)
    # map(println, sort(collect(D), by = x -> x[1], rev = false)); return
    sum(D) do (s, n)
        s ≥ save ? n : 0
    end
end

function solve3(M, si, ei)
    T = 20
    P = find_path(M, si, ei)
    N = length(P)
    A = Set()
    Q = Queue{Tuple{Any, Any, Any, Any, Any}}()
    S = Set()
    enqueue!(Q, (0, nothing, nothing, nothing, si))
    while !isempty(Q)
        s, cs, ce, ct, i = dequeue!(Q)
        # println("s=$s, cs=$cs, ce=$ce, ct=$ct, i=$i")

        # @assert isnothing(ce)

        # println("$s, $(N), $(N - 100), $(s ≥ N - 100)")
        # if s ≥ N - 100
            # continue
        # end
        # println("here")

        if i == ei
            ce = isnothing(ce) ? i : ce
            if s ≤ N - 100 && CartesianIndex(cs, ce) ∉ A
                push!(A, (CartesianIndex(cs, ce), s))
            end
        end

        if (i, cs, ce, ct) ∈ S
            continue
        end
        push!(S, (i, cs, ce, ct))

        if isnothing(cs)
            @assert M[i] != '#'
            enqueue!(Q, (s, i, nothing, T, i))
        end

        if !isnothing(ct) && M[i] != '#'
            @assert M[i] ∈ ".SE"
            push!(A, (cs, i, s))
        end

        if !isnothing(ct) && iszero(ct)
            continue
        else
            for d in cardinal_directions(2)
                j = i + d
                if !isnothing(ct)
                    @assert ct > 0
                    hasindex(M, j) || continue
                    enqueue!(Q, (s + 1, cs, nothing, ct - 1, j))
                else
                    hasindex(M, j) || continue
                    M[j] != '#' || continue
                    enqueue!(Q, (s + 1, cs, ce, ct, j))
                end
            end
        end
    end

    savings = [N - s for s in last.(A) if s ≥ 50]
    D = countmap(savings)
    haskey(D, 0) && pop!(D, 0)
    map(println, sort(collect(D), by = x -> x[1], rev = true))
    return

    # println(A)
    length(A)
end

function part2(data)
    si, ei = find_start(data), find_end(data)
    # this is very slow
    solve2(data, si, ei)
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
