# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

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

@memoize function score(i::Index, M::Matrix{Char})
    j = i + INDEX_DOWN
    hasindex(M, j) || return 1

    M[j] == '^' &&
        return score(j + INDEX_LEFT, M) + score(j + INDEX_RIGHT, M)

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
