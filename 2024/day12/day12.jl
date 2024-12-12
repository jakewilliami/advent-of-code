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

const Index = CartesianIndex{2}

function areas(data)
    D = DefaultDict(Set{Index})
    for i in CartesianIndices(data)
        c = data[i]
        push!(D[c], i)
    end

    D
end

function area(S)
    length(S)
end

function perimeter(S)
    r = 0
    for i in S
        r += 4
        for d in cardinal_directions(2)
            j = i + d
            if j ∈ S
                r -= 1
            end
        end
    end
    r
end

function are_cardinally_adjacent(i, j)
    for d in cardinal_directions(2)
        if i == (d + j)
            return true
        end
    end
    return false
end

function segments(S)
    S′ = sort(collect(deepcopy(S)))
    # i = pop!(S′)
    # V = [Set((i,))]
    V = []

    while !isempty(S′)
        Q = Queue{Index}()
        seen = Set{Index}()
        i = pop!(S′)
        enqueue!(Q, i)
        segment = Set{Index}()
        push!(segment, i)

        while !isempty(Q)
            i = dequeue!(Q)
            i ∈ seen && continue
            push!(seen, i)

            for d in cardinal_directions(2)
                j = i + d
                if j ∈ S′
                    push!(segment, j)
                    enqueue!(Q, j)
                    k = findfirst(==(j), S′)
                    @assert !isnothing(k)
                    deleteat!(S′, k)
                end
            end
        end
        push!(V, segment)
    end

    # println(V)
    return V



    # take two: flood fill or whatever it's called
    Q = Queue{Index}()
    S′ = sort(collect(deepcopy(S)))
    i = pop!(S′)
    enqueue!(Q, i)
    V = [Set((i,))]
    seen = Set{Index}()
    while !isempty(Q) && !isempty(S′)
        i = dequeue!(Q)
        if i ∈ seen
            continue
        end
        push!(seen, i)

        for d in cardinal_directions(2)
            j = i + d
            if j ∈ S′
                k = findfirst(==(j), S′)
                @assert !isnothing(k)
                deleteat!(S′, k)
                enqueue!(Q, j)
                for m in 1:length(V)
                    if any(are_cardinally_adjacent(j, l) for l in V[m])
                        push!(V[m], j)
                    end
                end
            end
        end
    end

    return V

    # take one:
    return
    S′ = deepcopy(S)
    V = []
    # push!(V, Set((pop!(S′),)))
    try_counter = 0
    while !isempty(S′)
        i = pop!(S′)
        found = false
        for k in 1:length(V)
            if any(are_cardinally_adjacent(i, j) for j in V[k]) && !found
                push!(V[k], i)
                found = true
            end
        end
        if !found
            if try_counter > 10
                push!(V, Set((i,)))
            else
                push!(S′, i)
            end
        end
        try_counter += 1
        # println(V)
    end
    return V
end

function part1(data)
    r = 0
    D = areas(data)

    for (k, v) in D
        for s in segments(v)
            a = area(s)
            p = perimeter(s)
            # println("$k: $a * $p = $(a * p)")
            r += (a * p)
        end
    end
    r
end

# for a given index, tell me the pairs of points between which there are sides
function _sides(i::Index)
    V = Set{NTuple{3, Index}}()
    for d in cartesian_directions(2)
        push!(V, (i, i + d, d))
    end
    V
end

function vert_elem(i::Index, j::Index)
    return min(first.(Tuple.((i, j)))...)
end

function horiz_elem(i::Index, j::Index)
    return min(last.(Tuple.((i, j)))...)
end

function count_adjacent(D_orig)
    # println(D_orig)
    r = 0
    for D in values(D_orig)
        s, e = extrema(keys(D))
        V = []
        # println("s=$s, e=$e")
        for i in s:e
            i ∈ keys(D) || continue
            found = false
            for k in 1:length(V)
                if any(i == (j - 1) || i == (j + 1) for j in V[k]) && !found
                    found = true
                    push!(V[k], i)
                end
            end
            if !found
                push!(V, [i])
            end
        end
        # println(V, " ", length(V))
        r += length(V)
    end
    r
end

function sides(S::Set{Index})
    V = []
    S′ = deepcopy(S)
    D = Dict() # DefaultDict(Set{Index}())

    # start by collecting position information about each side
    while !isempty(S′)
        i = pop!(S′)
        for d in cardinal_directions(2)
            j = i + d
            # ignore sides that are adjacent to each other
            if j ∉ S
                # add it to a dictionary
                # first direction, then vertical, then horiz
                # we also prefer top and left
                if !haskey(D, d)
                    D[d] = Dict()
                end
                # v = vert_elem(i, j)
                # v = vert_elem(j, j)
                vert = d ∈ (INDEX_UP, INDEX_DOWN)
                v = vert ? vert_elem(j, j) : horiz_elem(j, j)
                if !haskey(D[d], v)
                    D[d][v] = Dict()
                end
                # h = horiz_elem(i, j)
                # h = horiz_elem(j, j)
                h = vert ? horiz_elem(j, j) : vert_elem(j, j)
                if !haskey(D[d][v], h)
                    D[d][v][h] = 0
                end
                D[d][v][h] += 1
            end
        end
    end

    # now count sides
    # println(D)
    r = 0
    for (d, D′) in D
        # @info d
        # for (i, D′′) in D′
            # @info i
            r += count_adjacent(D′)
        # end
    end
    r
    # println(D)
    # length(V)
end

function part2(data)
    r = 0
    D = areas(data)

    for (k, v) in D
        for s in segments(v)
            l = sides(s)
            a = area(s)
            println("$k: $l * $a = $(l*a)")
            r += l * a
        end
    end
    r
end

function main()
    data = parse_input("data12.txt")
    # data = parse_input("data12.test2.txt")
    # data = parse_input("data12.test3.txt")
    data = parse_input("data12.test.txt")
    data = parse_input("data12.test4.txt")
    data = parse_input("data12.test5.txt")
    data = parse_input("data12.test2.txt")
    data = parse_input("data12.txt")

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
