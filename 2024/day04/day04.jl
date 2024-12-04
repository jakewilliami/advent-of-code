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
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function part1(data)
    l = "XMAS"
    r = 0
    for i in CartesianIndices(data)
        c = data[i]
        if c == 'X'
            for d in cartesian_directions(2)
                function f(off, c2)
                    j = CartesianIndex(i.I .+ (d.I .* off))
                    return hasindex(data, j) && data[j] == c2
                end
                if f(1, 'M') && f(2, 'A') && f(3, 'S')
                    r += 1
                end
            end
        end
    end
    r
end

function part2(data)
    l = "XMAS"
    r = 0
    for i in CartesianIndices(data)
        c = data[i]
        if c == 'A'
            tl = i + INDEX_TOP_LEFT
            tr = i + INDEX_TOP_RIGHT
            bl = i + INDEX_BOTTOM_LEFT
            br = i + INDEX_BOTTOM_RIGHT
            function f(j, c2)
                return hasindex(data, j) && data[j] == c2
            end

            if ((f(tl, 'M') && f(br, 'S')) || (f(tl, 'S') && f(br, 'M'))) && ((f(bl, 'M') && f(tr, 'S')) || (f(bl, 'S') && f(tr, 'M')))
                r += 1
            end
        end
    end
    r
end

function main()
    data = parse_input("data04.txt")
    # data = parse_input("data04.test.txt")

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
