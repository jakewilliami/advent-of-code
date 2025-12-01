#  ]add ~/projects/AdventOfCode Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools
# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = [(l[1], parse(Int, l[2:end])) for l in L]
    # L = get_integers.(L)
    return L
end

function part1(data)
    res = 50
    a = 0
    for (i, (d, n)) in enumerate(data)
        # done = false
        if res == 0
            a += 1
            # done = true
        end
        if d == 'L'
            res = mod(res - n, 100)
        elseif d == 'R'
            res = mod(res + n, 100)
        end
        # if d == 'L' && res == 0 && !done
            # a += 1
        # end
        # println("$d $n -> $d $res")

        # if i < length(data)
            # next_d = data[i + 1][1]
            # if res == 0 && next_d == 'L'
                # a += 1
            # end
        # end
    end
    return a
end

function part2(data)
    p  = 0x434C49434B
    res = 50
    a = 0
    #=for (d, n) in data
        h = false
        if res == 0
            a += 1
            h = true
        end

        m = d == 'L' ? -1 : 1
        # r = d == 'L' ? (res-1:-1:res-n+1) : (res+1:res+n-1)

        t = 0
        for n′ in r
            if n′ == 0
                t += 1
                a += 1
            end
            # res = mod(n′, 100)
        end

        if d == 'L'
            res = mod(res - n, 100)
        elseif d == 'R'
            res = mod(res + n, 100)
        end

        if res == 0
            a += 1
            h = true
        end

        println("$d $n - $res - $t - $h")
    end
    =#
    for (d, n) in data
        h = false
        if d == 'L'
            # if res == 0
                # a -= 1
            # end

            i = 0
            while i < n
                res = mod(res - 1, 100)
                if res == 0
                    a += 1
                    h = true
                end
                i += 1
            end
        elseif d == 'R'

            i = 0
            while i < n
                res = mod(res + 1, 100)
                if res == 0
                    a += 1
                    h = true
                end
                i += 1
            end
        end
        # println("$d $n - $res - $h - $a")
    end
    return a
end

function main()
    data = parse_input("data01.txt")
    # data = parse_input("data01.test.txt")
    # println(data)

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
