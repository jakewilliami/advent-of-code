# Each row of the data contains two numbers, so the whole data
# represents two columns of numbers, as if it were a spreadsheet.
# We read them into two vectors, which have the same length.
#
# The first problem requires us to sort each column and find
# the difference between the largest numbers in each list, second
# largest in each list, and so on, and sum the results.  This would
# be the Euclidean distance of the sorted lists.
#
# The second part of the problem states that we iterate through
# the left column and multiply its value but the number of occurrences
# of that number in the right column---they call this the similarity
# score---(and sum the results).

using StatsBase: countmap

function parse_input(input_file::String)
    L = Tuple{Int, Int}[Tuple(parse.(Int, split(l))) for l in readlines(input_file)]
    return first.(L), last.(L)
end

function part1(left::Vector{Int}, right::Vector{Int})
    return sum(abs(l - r) for (l, r) in zip(sort(left), sort(right)))
end

function part2(left::Vector{Int}, right::Vector{Int})
    counts = countmap(right)
    return sum(l * get(counts, l, 0) for l in left)
end

function main()
    left, right = parse_input("data01.txt")

    # Part 1
    part1_solution = part1(left, right)
    @assert part1_solution == 2344935
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(left, right)
    @assert part2_solution == 27647262
    println("Part 2: $part2_solution")
end

main()
