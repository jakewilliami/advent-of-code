# On this first day of Advent, our input is groups of integers, separated by new lines
# (groups are separated by a blank line).  Each integer represents the number of calories
# of a food item, and the groups represent each elf (who may be carrying multiple food
# items.
#
# Part 1 of the problem wants us to find the elf who is carrying the most calories.
# Part 2 wants us to find the three elves who are carrying the most calories (and add
# them together).

parse_input(input_file::String) =
    [[parse(Int, i) for i in split(s)] for s in split(read(input_file, String), "\n\n")]

part1(data::Vector{Vector{Int}}) = maximum(sum(d) for d in data)

part2(data::Vector{Vector{Int}}) = sum(sort([sum(d) for d in data], rev = true)[1:3])

function main()
    data = parse_input("data01.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 69289
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 205615
    println("Part 2: $part2_solution")
end

main()
