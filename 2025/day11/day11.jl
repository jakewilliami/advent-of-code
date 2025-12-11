# The input is a list of pairs; mappings.  The keys to the pairs are names, and
# the values are potentially many names that the key connects to.  Parsing this
# constructs a graph of nodes with the mappings defining edges.
#
# In part 1, we have to start at the key "you" and count how many paths there
# are to the key (or keys) "out".  This is trivially solvable with a BFS.
#
# In part 2, we have to find the number of paths to get from "svr" to "out", but
# you have to go through "dac" and "fft" nodes, first, in any order.  We use
# a recursive dynamic programming solution, very similar to our part 2 solution
# for day 7 [1].
#
# Important note: these all work because there are no cycles, so the input is
# a DAG.
#
# [1]: https://github.com/jakewilliami/advent-of-code/blob/2d3a6ad4/2025/day07/day07.jl

using DataStructures
using Memoization


### Parse Input ###

function parse_input(input_file::String)
    D = Dict{String, Vector{String}}()

    for line in eachline(input_file)
        a, b = split(line, ": ")
        D[a] = split(b)
    end

    return D
end


### Part 1 ###

const Map = Dict{String, Vector{String}}

function part1(data)
    count, start, stop = 0, "you", "out"

    Q = Queue{String}()
    enqueue!(Q, start)

    while !isempty(Q)
        s = dequeue!(Q)

        if s == stop
            count += 1
            continue
        end

        for s′ in data[s]
            enqueue!(Q, s′)
        end
    end

    return count
end


### Part 2 ###

# Really efficient dynamic programming solution from JP:
#   youtube.com/watch?v=3c453AH14-g
#   github.com/jonathanpaulson/AdventOfCode/blob/826497f7/2025/11.py#L21-L31
#
# The idea is to keep track of whether you have seen both intermediary nodes
# or not, rather than the whole path, because you don't need any more information.
@memoize function solve(s, data; dac=false, fft=false)
    # Base case: we have reached the end of the path.  Return whether or not
    # this path was valid.  If it is valid, we count it as one path.
    s == "out" && return dac && fft

    # Recursive case: count up all possibilities from the next steps in the path.
    return sum(data[s]) do s′
        solve(
            s′,
            data,
            dac = dac || s′ == "dac",
            fft = fft || s′ == "fft",
        )
    end
end

part2(data::Map) = solve("svr", data)


### Main ###

function main()
    data = parse_input("data11.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 494
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 296006754704850
    println("Part 2: $part2_solution")
end

main()
