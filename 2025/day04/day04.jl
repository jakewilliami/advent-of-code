# Simple problem today.  We were given a grid of either toilet paper rolls ('@')
# or empty space ('.').  We have a forklift and we are to find accessible toilet
# paper tolls.  A roll of toilet paper is accessible if it is surrounded by less
# than four other toilet paper rolls.
#
# In part 1, we are simply asked to count the number of immediately accessible
# toilet paper rolls.  In part 2, we had to keep removing the accessible rolls
# until there were none left (and count how many were removed all together).
#
# Today's problem was simple so I did it quite fast.  It helped that I had my
# library to help with these kinds of problems (though I always forget the API
# of my own library year by year).

using AdventOfCode.Parsing, AdventOfCode.Multidimensional


### Parse Input ###

parse_input(input_file::String) = readlines_into_char_matrix(input_file)


### Part 1 ###

function part1(data::Matrix{Char})
    # Iterate over the indices of the matrix, and for each toilet paper roll,
    # count the number of toilet paper rolls that are not surrounded by too
    # many other toilet paper rolls.
    return sum(CartesianIndices(data)) do i
        data[i] == '@' || return 0

        # Count the number of adjacent rolls of toilet paper
        n = sum(cartesian_directions(2)) do d
            j = i + d
            return hasindex(data, j) && data[j] == '@'
        end

        # Any more than four adjacent toilet paper rolls and we don't care
        return n < 4
    end
end


### Part 2 ###

function take_accessible_rolls!(M::Matrix{Char})
    # Find all of the accessible rolls of toilet paper (see part 1) and take
    # them out of the matrix.
    indices_to_remove = CartesianIndex[]

    n_removed = sum(CartesianIndices(M)) do i
        M[i] == '@' || return 0

        # Count the number of adjacent rolls of toilet paper
        n = sum(cartesian_directions(2)) do d
            j = i + d
            return hasindex(M, j) && M[j] == '@'
        end

        # Any more than four adjacent toilet paper rolls and we don't care
        if n < 4
            push!(indices_to_remove, i)
            return 1
        end

        return 0
    end

    # Modify the array to remove the rolls that we have dealt with
    for i in indices_to_remove
        M[i] = '.'
    end

    return n_removed
end

function part2(data::Matrix{Char})
    # Keep taking the rolls that are accessible until the state stops changing;
    # basic iterative process.
    prev_state, r = deepcopy(data), take_accessible_rolls!(data)
    while data != prev_state
        prev_state = deepcopy(data)
        r += take_accessible_rolls!(data)
    end

    return r
end


### Main ###

function main()
    data = parse_input("data04.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1344
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 8112
    println("Part 2: $part2_solution")
end

main()
