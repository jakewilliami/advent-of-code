using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections



function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = only(L)
    L = [parse(Int, c) for c in L]
    # L = get_integers.(L)
    return L
end

function expand(data)
    A = []
    j = 0
    for (i, x) in enumerate(data)
        if isodd(i)
            append!(A, fill(j, x))
            j += 1
        else
            append!(A, fill(nothing, x))
        end
    end
    A
end

function findfirst_empty(A)
    findfirst(isnothing, A)
end

function repr1(A)
    io = IOBuffer()
    for i in A
        if isnothing(i)
            print(io, '.')
        else
            print(io, i)
        end
    end
    String(take!(io))
end

function has_free_space(A)
    any(isnothing, A)
end

function trim_empty!(A)
    while !isempty(A) && isnothing(last(A))
        pop!(A)
    end
end

function left_align!(A)
    A′ = deepcopy(A)
    # A′ = Union{Int, Nothing}[nothing for _ in 1:length(A)]
    while has_free_space(A′)
        x = pop!(A′)
        isnothing(x) && continue
        i = findfirst_empty(A′)
        if !isnothing(i)
            # println("i=$i, x=$x")
            A′[i] = x
        else
            push!(A′, x)
        end
        # println(repr1(A′))
    end

    trim_empty!(A′)
    A′
end

function checksum(A)
    r = 0
    for (i, x) in enumerate(A)
        isnothing(x) && continue
        j = i - 1
        r += j*x
    end
    r
end

function part1(data)
    A = expand(data)
    A = left_align!(A)
    checksum(A)
end

function find_rightmost_start(A, start_id)
    for i in length(A):-1:1
        A[i] ≤ start_id && return i
    end
end

function findlast_nonempty(A, start_id)
    for i in find_rightmost_start(A, start_id):-1:1
        x = A[i]
        @assert x ≤ start_id
        if !isnothing(x)
            return i
        end
    end
    # findlast(!isnothing, A)
end

function findnext_rightmost_nonempty(A, i, start_id)
    j = find_rightmost_start(A, start_id)
    x = A[j]

    while 1 ≤ j ≤ length(A) && !isnothing(A[j]) && A[j] == x && A[j] ≤ start_id
        j -= 1
    end

    iszero(j) && return nothing
    return j + 1
end

function find_rightmost_chunk_span(A, start_id)
    i = findlast_nonempty(A, start_id)
    j = findnext_rightmost_nonempty(A, i, start_id)
    j, i
end

function find_leftmost_viable_chunk_index(A, n)
    for i in 1:(length(A)-n)
        if all(isnothing, A[i:(i+n-1)])
            return i
        end
    end
end

function last_nonempty(A)
    for i in length(A):-1:1
        if !isnothing(A[i])
            return A[i]
        end
    end
end

function has_viable_space(A, n)
    for i in 1:(length(A)-n)
        if all(isnothing, A[i:(i+n-1)])
            return true
        end
    end
    return false
end

function left_align_in_chunks!(A)
    A′ = deepcopy(A)
    # println(repr1(A))
    #
    # println(i,", ", j)
    # println(join(A[i:j]))

    for id in last_nonempty(A′):-1:0
        # splice!(A, 4:3, 2)
        indices = findall(==(id), A′)
        @assert all(indices[i - 1] == indices[i] - 1 for i in 2:length(indices))
        n = length(indices)
        if has_viable_space(A′, n)
            k = find_leftmost_viable_chunk_index(A′, n)
            any(k > ii for ii in indices) && continue  # edge case
            @assert !isnothing(k)
            x = []
            for i in indices
                push!(x, A′[i])
                A′[i] = nothing
            end
            # x = deleteat!(A′, indices)
            # println(x)
            splice!(A′, k:(k+n - 1), x)
            # println(repr1(A′))
        end
    end

    return A′


    while has_free_space(A′)

        id -= 1
        n = j - i + 1
        trim_empty!(A′)
        k = find_leftmost_viable_chunk_index(A′, n)
        isnothing(k) && continue
        for m in 1:n
            x = pop!(A′)
            A′[k + m - 1] = x
        end
        println(repr1(A′))
    end

    trim_empty!(A′)
    A′
end

function part2(data)
    A = expand(data)
    A = left_align_in_chunks!(A)
    checksum(A)
end

function main()
    data = parse_input("data09.txt")
    # data = parse_input("data09.test.txt")

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
