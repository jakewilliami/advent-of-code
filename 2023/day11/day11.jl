# Today was interesting.  Another matrix problem.  We had a grid of galaxies (#) and empty space (.).
# Each row and column that had no galaxies were to expand themselves.
#
# Part 1 of the problem required us to expand each row and column without galaxies in them once
# (i.e., they duplicate in-place).  Then, for each pair of galaxies, moving in only cardinal
# directions, find the smallest path between them and sum the results.  My initial implementation
# of this simulated the problem exactly as it stated it, and was very slow:
#   github.com/jakewilliami/advent-of-code/blob/664680f/2023/day11/day11.jl
# I used some BFS code to find the shortest path, which I copied from day 12 of last year.
#
# Part 2 of the problem did the classic thing: instead of each row duplicating once, rows and columns
# expand by one million.  It is no longer feasible to even construct such matrices, let alone simulate
# path-finding on them.  I was stumped.  I found a clever solution here:
#   https://www.reddit.com/r/adventofcode/comments/18fmrjk/comment/kcv853i/
# And implemented it in Julia.  I now understand that we don't need to do BFS because we can only
# move in cardinal directions.  As such, it is very easy to just multiply the rows we need to by an
# expansion coefficient.  I will have to remember this path-finding nuance for next time, and not over-
# complicate things so soon after I read the words "shortest" and "path"...

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Combinatorics

parse_input(input_file::String) = readlines_into_char_matrix(input_file)


### Part 1 ###

# Find axes without any galaxies
_axis_no_galaxies(data::Matrix{Char}; dims = 1) = Set{Int}(i for (i, s) in enumerate(eachslice(data, dims = dims)) if all(==('.'), s))
rows_no_galaxies(data::Matrix{Char}) = _axis_no_galaxies(data, dims = 1)
cols_no_galaxies(data::Matrix{Char}) = _axis_no_galaxies(data, dims = 2)
axes_no_galaxies(data::Matrix{Char}) = rows_no_galaxies(data), cols_no_galaxies(data)

# Find galaxies (and pairs of galaxy)
find_galaxies(data::Matrix{Char}) = findall(i -> data[i] == '#', CartesianIndices(data))
galaxy_pairs(galaxies::Vector{CartesianIndex{2}}) = combinations(galaxies, 2)
galaxy_pairs(data::Matrix{Char}) = galaxy_pairs(find_galaxies(data))

# Calculate the shortest path between two galaxies, g1 and g2
function shortest_path(g1::CartesianIndex, g2::CartesianIndex, empty_rows::Set{Int}, empty_cols::Set{Int}; expand_coeff::Int = 1)
    n = max(expand_coeff - 1, 1)

    # Because you can go through any point in the grid (i.e., other galaxies) to
    # get to your destination, the fastest path to the target (other galazy) is
    # diagonally.  However, because you can't go diagonally, zig-zagging the fastest
    # route to the target.  In a grid, zig-zagging towards the target is equivalent
    # to going horizontally to the column above or below the target, and then going
    # vertically towards the target (i.e., in Pythagorean terms, c² = (a + b)²).
    # To calculate this, we need to find the actual distance between the two galaxies
    # on both dimensions.
    a, b = min(g1, g2), max(g1, g2)  # wish `minmax' worked on CartesianIndices
    (ay, ax), (by, bx) = a.I, b.I
    dy, dx = Tuple(b - a)

    # https://www.reddit.com/r/adventofcode/comments/18fmrjk/comment/kcv853i/
    # Instead of simulating the maxtrix and expanding etc., we just find the number
    # of rows/columns between the two galaxies that overlap with the empty rows,
    # and add them n times to the distance between the two points.
    return dy + length(empty_rows ∩ (ay:by)) * n +
        dx + length(empty_cols ∩ (ax:bx)) * n
end

# Sum the shortest paths between all galaxy pairs
function sum_shortest_paths(data::Matrix{Char}; expand_coeff::Int = 1)
    rs, cs = axes_no_galaxies(data)
    return sum(shortest_path(g1, g2, rs, cs, expand_coeff = expand_coeff) for (g1, g2) in galaxy_pairs(data))
end

part1(data::Matrix{Char}) = sum_shortest_paths(data)


### Part 2 ###

part2(data::Matrix{Char}) = sum_shortest_paths(data, expand_coeff = 1_000_000)

function main()
    data = parse_input("data11.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 9742154
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 411142919886
    println("Part 2: $part2_solution")
end

main()
