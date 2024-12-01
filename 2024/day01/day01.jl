using StatsBase: countmap

function parse_input(input_file::String)
    L = Tuple{Int, Int}[Tuple(parse.(Int, split(l))) for l in readlines(input_file)]
    return first.(L), last.(L)
end

function part1(left::Vector{Int}, right::Vector{Int})
    sort!(left)
    sort!(right)
    sum(abs(l - r) for (l, r) in zip(left, right))
end

function part2(left::Vector{Int}, right::Vector{Int})
    counts = countmap(right)
    sum(l * get(counts, l, 0) for l in left)
end

function main()
    left, right = parse_input("data01.txt")

    # Part 1
    part1_solution = part1(deepcopy(left), deepcopy(right))
    @assert part1_solution == 2344935
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(left, right)
    @assert part2_solution == 27647262
    println("Part 2: $part2_solution")
end

main()
