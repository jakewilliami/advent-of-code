# We are given a list of instructions to create a "trench" for some lava.
# The instructions are of the form:
#   Direction Magnitude HexColour
# So we have to dig for `Magnitude' blocks in `Direction' direction, and
# paint the wall of this trench the `HexColour'.  After following all the
# trench instructions, we have to dig down in the inside of the trench so
# that lava can fill the space.
#
# In part 1 of the problem, after constructing the trench and hole, we are
# to calculate the total area of this hole.  Initially, I started simulating
# this with an array, but as we were growing the array backwards when we
# went in negative directions, I had some trouble with offsets that I didn't
# want to debug, so I did some research and found some nice algorithms that
# help with exactly this kind of problem.  Namely, the Shoelace Formula, which
# computes the area of a given polygon, as well as Pick's Theorem, which is
# used to compute the inner area of the polygon.
#
# I enjoyed this as I had never heard of these algorithms before.  Learning
# new algorithms reminds me of Bresenham's line algorithm that I learned
# about on day 5 of 2021, or the Shunting-yard algorithm that I learned
# about on day 18 of 2020.
#
# Part 2 of the problem would have been difficult had I continued down the
# realistic simulation route, however it was not hard to extend the polygon
# algorithms to find a working solution.  (The premise of this part was that
# the colour that we "painted the walls with" is actually a distance, so
# the area is much larger.)  This part of the problem has been optimised with
# inspiration from Jake Gordon's answer:
#   https://git.sr.ht/~jgordon/aoc/tree/main/item/2023/D18/D18.jl

using AdventOfCode.Multidimensional
using Base.Iterators, IterTools
using LinearAlgebra

struct Instruction
    direction::Direction
    magnitude::Int
    colour::String
end

function parse_input(input_file::String)
    directions = Dict{Char, Direction}(
        'U' => INDEX_UP,
        'D' => INDEX_DOWN,
        'R' => INDEX_RIGHT,
        'L' => INDEX_LEFT,
    )

    L = Instruction[]
    for line in eachline(input_file)
        d, n, c = split(line)

        direction = directions[only(d)]
        magnitude = parse(Int, n)

        inst = Instruction(direction, magnitude, c[3:(end - 1)])
        push!(L, inst)
    end

    return L
end


### Part 1 ###

Base.length(f::Iterators.Flatten) = sum(length, f.it)

# Get the indices of the outline---i.e., the trench.  We get these as an
# iterator in the interest of memory/efficiency
function get_trench_indices(data::Vector{Instruction})
    i = origin(2)
    indices = Vector{CartesianIndices{2}}(undef, length(data))

    for (k, inst) in enumerate(data)
        d, n = inst.direction, inst.magnitude
        t = d.I

        # Calculate the range of indices given by the current instruction
        s = CartesianIndex(ntuple(k -> t[k] == 0 ? 1 : t[k], 2))
        j = i + (d * (n - 1))
        r = i:s:j

        # Add this range of indices to the output list, and increment i
        indices[k] = r
        i = j + d
    end

    return Iterators.flatten(indices)
end

function trench_area(data::Vector{Instruction})
    indices = get_trench_indices(data)
    perimeter = length(indices)

    # Compute the area of the polygon using the Shoelace formula:
    #   https://www.wikiwand.com/en/Shoelace_formula#Triangle_formula
    #
    # Optimisation by vectorised formula inspired by this solution:
    #   https://www.reddit.com/r/adventofcode/comments/18l0qtr/comment/kdv4m8p/
    # See also my previous (slow) solution:
    #   https://github.com/jakewilliami/advent-of-code/blob/8ccdc37/2023/day18/day18.jl
    enclosed, perimeter, r = 0.0, 0, rand()
    α, β = -r, 1 - r
    x = zeros(Int, 2)
    x = (0, 0)
    for inst in data
        d, n = Tuple(inst.direction), inst.magnitude
        perimeter += n
        enclosed += n .* dot((α, β) .* reverse(x), d)
        x = x .+ n .* d
    end

    return round(Int, abs(enclosed)) + perimeter ÷ 2 + 1
end

part1(data::Vector{Instruction}) = trench_area(data)


### Part 2 ###

# Re-process input as per prompt for part 2
function _reprocess_input!(data::Vector{Instruction})
    directions = (INDEX_RIGHT, INDEX_DOWN, INDEX_LEFT, INDEX_UP)

    for (i, inst) in enumerate(data)
        direction = directions[Int(inst.colour[end]) - 47]
        magnitude = parse(Int, inst.colour[1:(end - 1)], base=16)
        data[i] = Instruction(direction, magnitude, inst.colour)
    end

    return data
end

function part2(data::Vector{Instruction})
    _reprocess_input!(data)
    return trench_area(data)
end

function main()
    data = parse_input("data18.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 62500
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 122109860712709
    println("Part 2: $part2_solution")
end

main()
