# We were given a grid of characters in today's input, and we had to perform
# what was essentially a word search.
#
# In part 1, we had to find all of the instances where the word "XMAS" appeared
# in the grid.  This was straight forward, as you iterate over the indices of
# the grid, and if you find an X, check for the rest of the word in the
# surrounding directions (including diagonally).
#
# In part 2, we had to find a cross of "MAS"s.  This was just as simple; iterate
# over the indices of the grid, and if you find an A, you might be in the middle
# of a cross of "MAS"s, so you check the immediately adjacent diagonal indices
# for the appropriate letters, and cound the results.

using AdventOfCode.Parsing, AdventOfCode.Multidimensional

parse_input(input_file::String) = readlines_into_char_matrix(input_file)

# Check that a string is present in the character array starting at i in the
# given direction
function string_in_direction(
    data::AbstractArray{Char, N},
    i::CartesianIndex{N},
    dir::CartesianIndex{N},
    expected::String,
) where {N}
    all(eachindex(expected)) do j
        c = expected[j]
        v = tryindex(data, i + (dir * j))
        !isnothing(v) && v == c
    end
end

function part1(data::Matrix{Char})
    # All possible positions in the input matrix may be a valid starting point
    return sum(CartesianIndices(data)) do i
        # If the current character is not X (for XMAS), then this is not a
        # valid starting point
        data[i] == 'X' || return 0

        # Check if the remainder of XMAS is present in any cartesian direction
        # from the current position
        sum(cartesian_directions(ndims(data))) do d
            string_in_direction(data, i, d, "MAS")
        end
    end
end

# Check that values `end1` and `end2` are on either diagonal side of the index
# given in the specified diagonal direction.
#
# See also `is_diagonal`:
# <https://github.com/jakewilliami/AdventOfCode.jl/blob/a0102896/src/multidimensional/directions.jl#L56-L68>
function diagonal_adjacencies_are_values(
    data::AbstractArray{T, N},
    i::CartesianIndex{N},
    dir::CartesianIndex{N},
    end1::T,
    end2::T,
) where {T, N}
    function check_expected_in_direction(
        i::CartesianIndex{N},
        dir::CartesianIndex{N},
        expected::T,
     )
        v = tryindex(data, i + dir)
        return !isnothing(v) && v == expected
    end

    d1, d2 = dir, opposite_direction(dir)

    # There are two options: the word is read from left to right or
    # right to left.  We have to check both possibilities
    option1 = check_expected_in_direction(i, d1, end1) &&
        check_expected_in_direction(i, d2, end2)
    option2 = check_expected_in_direction(i, d1, end2) &&
        check_expected_in_direction(i, d2, end1)

    return option1 || option2
end

function part2(data::Matrix{Char})
    sum(CartesianIndices(data)) do i
        data[i] == 'A' || return 0

        # There are two directions we need to check to make the X:
        #   - Descending diagonal (top-left to bottom-right); and
        #   - Ascending diagonal (bottom-left to top-right).
        #
        # We only need to specify the left-most direction of the
        # diagonal to the function.
        mas1 = diagonal_adjacencies_are_values(data, i, INDEX_TOP_LEFT, 'M', 'S')
        mas2 = diagonal_adjacencies_are_values(data, i, INDEX_BOTTOM_LEFT, 'M', 'S')

        mas1 && mas2
    end
end

function main()
    data = parse_input("data04.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 2458
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 1945
    println("Part 2: $part2_solution")
end

main()
