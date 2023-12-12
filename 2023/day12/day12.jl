using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

# . operational
# # damaged
# ? unknown

function parse_input(input_file::String)
    # get_integers
    # readlines_into_char_matrix
    # readlines_into_int_matrix
    L = readlines(input_file)
    L = [split(s) for s in L]
    L = [(l1, parse.(Int, split(l2, ','))) for (l1, l2) in L]
    # L = [(collect(l1), l2) for (l1, l2) in L]
    return L
end

function _arrangement(line)
    # (char, start i, length)
    A = []
    n, i, j, c = 1, 1, 1, line[1]
    while i < length(line)
        # println("$i $n $c $(line[i]) $(line[i+1])")
        i += 1
        c2 = line[i]
        if c2 != c
            push!(A, (c, j, n))
            c = c2
            n = 1
            j = i
        else
            n += 1
        end
        i == length(line) && push!(A, (c, j, n))
    end
    return A
end

# ci = current position within dots
# bi = current position within blocks
# ai = current position within arrangement
# li == length of current block of '#'
# state space is len(line)^2 * len(blocks)
function n_arrangements(line, blocks, ci, bi, li, D = Dict())
    # config, blocks = line
    # arr = arrangement(config)
    # println("BEFORE: '$config', $blocks, $arr")

    # First: find ones that are accounted for
    #=I = []
    for (i, (c, n)) in enumerate(arr)
        c == '#' || continue
        j = findfirst(==(n), blocks)
        if j !== nothing
            deleteat!(blocks, j)
            push!(I, i)
        end
    end
    deleteat!(arr, I)=#

    # Go left to right, bfs??
    # D = Dict()
    # ci, bi, cb = 1, 1, blocks[1]
    # for (i, c) in enumerate(line)
        # if ci == length()
    # end
    # char, start i, block length
    # c1, si, bl = arrangement[ai]
    # if ci == si + bl - 1
    # https://github.com/jonathanpaulson/AdventOfCode/blob/341185efbe64ce771a57aef7d2bd101d9ea09329/2023/12.py
    # https://www.reddit.com/r/adventofcode/comments/18ge41g/comment/kd03uf3/
    k = (ci, bi, li)
    k in keys(D) && return D[k]
    if ci == (length(line) + 1)
        if bi == (length(blocks) + 1) && li == 0
            return 1
        elseif bi == length(blocks) && blocks[bi] == li
            return 1
        else
            return 0
        end
    end
    ans = 0
    for c in ('.', '#')
        if line[ci] in (c, '?')
            if c == '.' && li == 0
                ans += n_arrangements(line, blocks, ci + 1, bi, 0, D)
            elseif c == '.' && li > 0 && bi <= length(blocks) && blocks[bi] == li
                ans += n_arrangements(line, blocks, ci + 1, bi + 1, 0, D)
            elseif c == '#'
                ans += n_arrangements(line, blocks, ci + 1, bi, li + 1, D)
            end
        end
    end
    D[k] = ans
    return ans

    # println("AFTER : '$config', $blocks, $arr")


    return 0
end

function part1(data)
    res = 0
    # println(arrangement(first(last(data))))
    for (line, blocks) in data
        # arrangement = _arrangement(line)
        res += n_arrangements(line, blocks, 1, 1, 0)
        # println(n_arrangements(line, blocks, 1, 1, 0))
    end
    return res
end

function part2(data)
    res = 0
    repeat_coeff = 5
    # println(arrangement(first(last(data))))
    # println(D)
    for (line, blocks) in data
        D = Dict()
        # arrangement = _arrangement(line)
        # print(blocks)
        line = join(repeat([line], repeat_coeff), '?')
        blocks = repeat(blocks, repeat_coeff)
        # println("$line $blocks")
        # println(" -> $blocks")
        res += n_arrangements(line, blocks, 1, 1, 0, D)
        # println(D)
        # println(n_arrangements(line, blocks, 1, 1, 0, D))
    end
    return res
end

function main()
    data = parse_input("data12.txt")
    # data = parse_input("data12.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
    # 7776000 too low
    # 1024000 too low
end


main()
