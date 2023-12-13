using AdventOfCode
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
    L = read(input_file, String)
    return AdventOfCode.Parsing._lines_into_matrix.(split.(split(L, "\n\n"), '\n'))
    return readlines_into_char_matrix.(split())
    L = readlines(input_file)
    return L
end

function is_reflective_rows(M, i)
    # a, b = M[1:i, :], M[(i + 1):end, :]
    nrows = length(axes(M, 1))
    max_reflection = max(min(i, nrows - i), 1)
    # max_reflection = max(max_reflection, 1)
    # a, b = M[(nrows - max_reflection):i, :], M[max_reflection:end, :]
    # a, b = M[(i - max_reflection + 1):i, :], M[(i+1):(nrows - max_reflection + 1), :]
    a = M[max(i - max_reflection + 1, 1):i, :]
    b = M[(i + 1):min(i + max_reflection, nrows), :]
    # println("Rows: ", i, " ", max_reflection, " ", length(axes(M, 1)))
    # display(a)
    # display(reverse(b, dims=1))
    # println()
    return a == reverse(b, dims=1)
    return false
end

function is_reflective_cols(M, i)
    # a, b = M[:, 1:i], M[:, (i + 1):end]
    ncols = length(axes(M, 2))
    max_reflection = max(min(i, ncols - i), 1)
    # max_reflection = max(max_reflection, 1)
    # a, b = M[:, (i - max_reflection + 1):i], M[:, (i+1):(ncols - max_reflection + 1)]
    a = M[:, max(i - max_reflection + 1, 1):i]
    b = M[:, (i + 1):min(i + max_reflection, ncols)]
    # println("Cols: ", i, " ", max_reflection, " ", length(axes(M, 2)))
    # display(a)
    # display(reverse(b, dims=2))
    # println()
    return a == reverse(b, dims=2)
    return false
end

function is_reflective(M, axis, i)
    axis == 1 && return is_reflective_rows(M, i)
    axis == 2 && return is_reflective_cols(M, i)
    return nothing
end

function find_reflection(M, not = nothing)
    for i in axes(M, 1)
        # i == 1 && continue
        i == length(axes(M, 1)) && continue
        if is_reflective(M, 1, i) && (1, i) != not
            return 1, i
        end
    end

    for i in axes(M, 2)
        # i == 1 && continue
        i == length(axes(M, 2)) && continue
        if is_reflective(M, 2, i) && (2, i) != not
            return 2, i
        end
    end

    return nothing, nothing
end

function score_reflection(M, a, r)
    a == 1 && return 100r
    a == 2 && return r
    return nothing
end

function part1(data)
    res = 0
    for M in data
        a, r = find_reflection(M)
        # println(a," ", r)
        res += score_reflection(M, a, r)
    end
    return res
end

function flip_smudge!(M, i)
    c = M[i]
    if c == '.'
        M[i] = '#'
        # println("dot ($c => $(M[i]))")
    elseif c == '#'
        M[i] = '.'
        # println("hash ($c => $(M[i]))")
    else
        error("unreachable")
    end
    return M
end

function find_new_reflection(M)
    function new_reflection_valid(a1, r1, a0, r0)
        a1 !== nothing || return false
        r1 !== nothing || return false
        return (a1, r1) != (a0, r0)
    end

    a, r = find_reflection(M)
    a0, r0 = a, r

    # println("original: ", r, " (axis $a)")
    for i in CartesianIndices(M)
        # println("trying $i")
        M2 = deepcopy(M)
        flip_smudge!(M2, i)
        a2, r2 = find_reflection(M2, (a0, r0))
        # flip_smudge!(M2, i)
        # @assert M == M2
        # println(a2, " ", r2, " ($i)")
        # println()
        # println(join((join(r) for r in eachrow(M)), "\n"))
        # println()
        # println(join((join(r) for r in eachrow(M2)), "\n"))
        # println(); println()
        # display(M2)
        # display(M)
        # display(M2)
        # if (a2, r2) !== (nothing, nothing) && (a, r) != (a2, r2)
        if new_reflection_valid(a2, r2, a0, r0)
            # println("!!! $i ($a2, $r2)")
            a, r = a2, r2
            # display(M2)
            break
        else
            i == last(CartesianIndices(M)) && println("WARN: no new reflection found")
        end
    end
    @assert (r, a) != (r0, a0) "r=$r == new r=$r0, (a, a0)=($a, $a0)" #(a, r) != (a0, r0)
    # println(a," ", r)
    # println()
    return a, r
end

function find_new_reflection2(M)
    a, r = find_reflection(M)
    a0, r0 = a, r
    for i in CartesianIndices(M)
        M2 = deepcopy(M)
        c = M2[i]
        c == '.' && (M2[i] = '#')
        c == '#' && (M2[i] = '.')
        a1, r1 = find_reflection(M2)

        if r1 !== nothing && (a1, r1) != (a0, r0)
            a, r = a1, r1
            break
        end
    end
    println("a=$a, r=$r")
    @assert (a, r) != (a0, r0)
end

function part2(data)
    res = 0
    for M in data
        a, r = find_new_reflection(M)
        res += score_reflection(M, a, r)
    end
    return res
end

function main()
    data = parse_input("data13.txt")
    # data = parse_input("data13.test.txt")

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 33047
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
    # not 37107 too high
end

main()
