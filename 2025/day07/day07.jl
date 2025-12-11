# Here, we are given a grid.  We start at the top.  We shine a beam of light down
# the grid, and each time we reach a splitter (^), this splits the beam into two.
#
# In part 1, we are asked to count the number of times the beam is split.  This is
# a simple BFS problem that we can do easily.
#
# Part 2 is harder.  We have to count all possible paths for the beam to take, when
# it is split.  We use a recursive dynamic programming solution.
#
# This was a straight forward day in a sense, but part 2 was non-trivial and took me
# a while to come to a recursive solution, because I tried to do it iteratively.  It
# ends up being much simpler using recursion.

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Memoization
using DataStructures


### Parse Input ###

const Index = CartesianIndex

parse_input(input_file::String) = readlines_into_char_matrix(input_file)


### Part 1 ###

function part1(M::Matrix{Char})
    si, res = findfirst(==('S'), M), 0
    Q, seen = Queue{Index}(), Set{Index}()

    # Push the starting index to the queue
    push!(Q, si)

    # Count number of splits
    while !isempty(Q)
        i = popfirst!(Q)

        # Skip this one if we have already handled it
        i ∈ seen && continue
        push!(seen, i)

        # If we see a splitter, we need to split the beam to the left and right
        # Here, we assume both left and right of the splitter exists
        if M[i] == '^'
            push!(Q, i + INDEX_LEFT)
            push!(Q, i + INDEX_RIGHT)

            # Importantly, when we split the mean, we could one towards the
            # final answer
            res += 1
            continue
        end

        # If there is no splitter, we continue downwards
        j = i + INDEX_DOWN
        hasindex(M, j) && push!(Q, j)
    end

    return res
end


### Part 2 ###
# Dynamic programming solution from JP:
#   youtube.com/watch?v=hiNMPy_VvHY
#   github.com/jonathanpaulson/AdventOfCode/blob/826497f7/2025/7.py#L16-L23
@memoize function score(i::Index, M::Matrix{Char})
    # Base case: the beam is out of bounds and cannot go further, so we
    # have reached the end of the path.  We count this as one path.
    j = i + INDEX_DOWN
    hasindex(M, j) || return 1

    # Splitter case: the beam has been split; add up the resulting possible
    # paths from either side of the splitter.
    M[j] == '^' &&
        return score(j + INDEX_LEFT, M) + score(j + INDEX_RIGHT, M)

    # Trivial case: no splitter is found, so advance the beam downward
    return score(j, M)
end

function part2(M::Matrix{Char})
    si = findfirst(==('S'), M)
    return score(si, M)
end


### Main ###

function main()
    data = parse_input("data07.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1592
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 17921968177009
    println("Part 2: $part2_solution")
end

main()
