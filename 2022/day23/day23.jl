using Base: DirectOrdering, hash_uint
# Today was pretty simple, but I took a while to do it because I had some silly bugs which
# were a little tricky to debug.
#
# We were given a map where elves were, and some simple rules about where the elves could
# move.  In part one, we simply had to model the elves moving for ten rounds.
#
# In part two, we had to model the elf ecosystem until they didn't change their movements.
#
# The implementation is pretty straight forward.  I'm modelling it simply using a character
# array.  There is probably a better solution.  The only complexity came from reading the
# instructions carefully.


using AdventOfCode.Multidimensional

using MultidimensionalTools
using StatsBase


parse_input(data_file::String) = readlines_into_char_matrix(data_file)


### Part 1

const N = CartesianIndex(-1, 0)
const NE = CartesianIndex(-1, 1)
const E = CartesianIndex(0, 1)
const SE = CartesianIndex(1, 1)
const S = CartesianIndex(1, 0)
const SW = CartesianIndex(1, -1)
const W = CartesianIndex(0, -1)
const NW = CartesianIndex(-1, -1)


const DirectionDefinition = Tuple{CartesianIndex{2}, NTuple{3, CartesianIndex{2}}}


function no_surrounding_elves(i::CartesianIndex{2}, M::Matrix{Char})
    return all(cartesian_directions(2)) do d
        j = i + d
        hasindex(M, j) ? M[j] == '.' : true
    end
end


function findfirst_valid_direction(
    i::CartesianIndex{2},
    M::Matrix{Char},
    dirs::Vector{DirectionDefinition},
)
    # If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving
    # one step.  If there is no Elf in the S, SE, or SW adjacent positions, the Elf proposes
    # moving south one step.  If there is no Elf in the W, NW, or SW adjacent positions, the
    # Elf proposes moving west one step.  If there is no Elf in the E, NE, or SE adjacent
    # positions, the Elf proposes moving east one step.

    for (d, dirs′) in dirs
        if all(dirs′) do d′
            j = i + d′
            hasindex(M, j) ? M[j] == '.' : true
        end
            return i + d
        end
    end

    return i
end


function round_first_half(
    i::CartesianIndex{2},
    M::Matrix{Char},
    dirs::Vector{DirectionDefinition},
)
    # Each Elf considers the eight positions adjacent to themself. If no other Elves are in
    # one of those eight positions, the Elf does not do anything during this round.
    no_surrounding_elves(i, M) && return i

    # Otherwise, the Elf looks in each of four directions in the following order and
    # proposes moving one step in the first valid direction
    return findfirst_valid_direction(i, M, dirs)
end


function simulate_elves(M::Matrix{Char}, dirs::Vector{DirectionDefinition})
    elves = CartesianIndex{2}[i for i in CartesianIndices(M) if M[i] == '#']
    proposed_moves = Dict{CartesianIndex{2}, CartesianIndex{2}}(
        elf => round_first_half(elf, M, dirs) for elf in elves
    )
    proposed_moves_count = countmap(values(proposed_moves))

    # If two or more Elves propose moving to the same position, none of those Elves move
    moves = Dict{CartesianIndex{2}, CartesianIndex{2}}(
        elf_i => move_i for
        (elf_i, move_i) in proposed_moves if isone(proposed_moves_count[move_i])
    )

    # Expand matrix if needed
    needs_expanding = any(!hasindex(M, move_i) for (_, move_i) in moves)
    if needs_expanding
        M = append_n_times(M, 1, '.', dims = 1)
        M = append_n_times(M, 1, '.', dims = 2)
        M = append_n_times_backwards(M, 1, '.', dims = 1)
        M = append_n_times_backwards(M, 1, '.', dims = 2)
    end

    # move simultaneously
    for (i, elf_i) in enumerate(elves)
        haskey(moves, elf_i) || continue
        move_i = moves[elf_i]

        # Adjust indices if the matrix needed expanding
        if needs_expanding
            elf_i += CartesianIndex{2}()
            move_i += CartesianIndex{2}()
        end

        # Move
        M[elf_i] = '.'
        M[move_i] = '#'
    end

    return M
end


function part1(M::Matrix{Char})
    M = deepcopy(M)
    dirs = DirectionDefinition[
        (N, (N, NE, NW)),
        (S, (S, SE, SW)),
        (W, (W, NW, SW)),
        (E, (E, NE, SE)),
    ]

    # Simulate elves for ten rounds
    for _ = 1:10
        M = simulate_elves(M, dirs)

        # Change first considered direction
        circshift!(dirs, 1)
    end

    # Our answer is the number of empty squares in the smallest box around the elves
    indices = (Tuple(i) for i in CartesianIndices(M) if M[i] == '#')
    r1, r2 = extrema(map(first, indices))
    c1, c2 = extrema(map(last, indices))
    return count(==('.'), M[r1:r2, c1:c2])
end


### Part 2

function part2(M::Matrix{Char})
    M = deepcopy(M)
    dirs = DirectionDefinition[
        (N, (N, NE, NW)),
        (S, (S, SE, SW)),
        (W, (W, NW, SW)),
        (E, (E, NE, SE)),
    ]

    M_id, round_n = hash(M), 1
    while true
        M = simulate_elves(M, dirs)

        # If no elves have moved, we have found our answer
        curr_M_id = hash(M)
        if curr_M_id == M_id
            return round_n
        end

        # Reset previous map and increment round number
        M_id = curr_M_id
        round_n += 1

        # Change first considered direction
        circshift!(dirs, 1)
    end
end


### Main

function main()
    M = parse_input("data23.txt")

    # Part 1
    part1_solution = part1(M)
    @assert part1_solution == 3874 part1_solution
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(M)
    @assert part2_solution == 948
    println("Part 2: $part2_solution")
end

main()
