# We are given a grid of characters.  We have to group them by their value, and by
# whether or not they are adjacent.  In part one, we count each group's perimeter
# (that is, the number of squares that are exposed to the outside), and in part two,
# the number of sides.
#
# I was quite slow today.  Part one took me a little while to figure out (with some
# trial and error) exactly the kind of solution we need to write (i.e., a flood fill
# one).  It reminded me of day 18 of 2022 (the lava)---and a bit of part two of day
# 10 from last year.
#
# My solution for part two is really bad.  It works and it's somewhat efficient, but
# it's not the best solution.  It took me a while to think of it, but I realise now
# that in order to get the sides of the objects, you can just count the corners (or
# the indices with two adjacent elements).

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using DataStructures


### Parse Input ###

parse_input(input_file::String) = readlines_into_char_matrix(input_file)

const Index = CartesianIndex{2}


### Part 1 ###

# Given a matrix, group the (possibly non-adjacent) indices by their data value
function areas(data::Matrix{Char})
    D = DefaultDict(Set{Index})

    for i in CartesianIndices(data)
        c = data[i]
        push!(D[c], i)
    end

    return D
end

# Get the "area" of a set of adjacent indices; that is, how many squares
# does it take up in the matrix?
area(S::Set{Index}) = length(S)

# Get the "perimeter" of a set of adjacent indices; that is, how many sides
# are showing if you trace around it
function perimeter(S::Set{Index})
    return sum(S) do i
        # In two dimensions, everything has four sides unless proven otherwise
        n = 4

        # If there is an adjacent index in this set, we must not count this
        # side towards the perimeter
        n -= sum((i + d) ∈ S for d in cardinal_directions(2))

        n
    end
end

# Check if index i is adjacent (in any of the four cardinal directions) to
# index j
are_cardinally_adjacent(i::Index, j::Index) =
    any(i == (d + j) for d in cardinal_directions(2))

# Given a set of (possibly non-adjacent) indices, segment them into the
# ones that are cardinally adjacent to one another.  We do this by doing
# a "flood fill" on elements in the set until we have discovered all
# segments.  That is, a BFS into each cardinal direction of elements
# in the set.
function segments(S::Set{Index})
    S′ = deepcopy(S)
    V = Set{Index}[]

    while !isempty(S′)
        # For each iteration, perform a flood fill starting at some
        # element of S′ and finding all adjacent elements
        Q, seen = Queue{Index}(), Set{Index}()
        i = pop!(S′)
        enqueue!(Q, i)
        segment = Set{Index}((i,))

        while !isempty(Q)
            i = dequeue!(Q)
            i ∈ seen && continue
            push!(seen, i)

            for d in cardinal_directions(2)
                j = i + d
                if j ∈ S′
                    push!(segment, j)
                    enqueue!(Q, j)

                    # Importantly, if we have found an adjacent element
                    # in the set, we must delete it from the set to
                    # indicate that it is used by a known segment
                    delete!(S′, j)
                end
            end
        end

        # Add the discovered segment to the overall list
        push!(V, segment)
    end

    return V
end

# For each group of object, add its area multiplied by its perimeter
function part1(data::Matrix{Char})
    D = areas(data)
    return sum(values(D)) do S
        sum(segments(S)) do s
            area(s) * perimeter(s)
        end
    end
end


### Part 2 ###

vert(i::Index) = first(Tuple(i))
horiz(i::Index) = last(Tuple(i))

# Given a set of integers (representing either vertical or horizontal
# coordinates, it will count the number of adjacent groups of integers.
# For example, [1, 2, 3, 4, 5] -> 1, but [1, 3, 5] -> 3.
function count_adjacent(S::Set{Int})
    s, e = extrema(S)
    V = Set{Int}[]
    for i in s:e
        i ∈ S || continue

        # Find a matching group of adjacent elements
        found = false
        for k in 1:length(V)
            if any(abs(i - j) == 1 for j in V[k])
                found = true
                push!(V[k], i)
                break
            end
        end

        # If we haven't found a group that has an adjacent element,
        # we need to make a new one
        found || push!(V, Set((i,)))
    end

    return length(V)
end

# This (very messy) code takes a set of adjacent indices and will count
# the number of sides that block of indices has.  It does this by storing
# information about each side in a dictionary and counting the number
# of distinct groups of side information...
function sides(S::Set{Index})
    S′ = deepcopy(S)

    # This dictionary stores information about each side; first direction,
    # then the unchanged component of the edge  (i.e., the horizontal
    # component of the edge if the edge goes left to right, or the vertical
    # component if not); and then the changeable component of the edge.
    # We are required to keep track of the final step because this will
    # allow us to discern whether a side in a particular direction at a
    # particular vertical or horizontal index makes up one or more distinct
    # sides (see `count_adjacent`).
    D = Dict{Index, Dict{Int, Set{Int}}}()

    # Start by collecting position information about each side
    while !isempty(S′)
        i = pop!(S′)
        for d in cardinal_directions(2)
            j = i + d
            # Ignore sides that are adjacent to each other
            j ∈ S && continue

            # Add this side to a dictionary
            if !haskey(D, d)
                D[d] = Dict{Int, Set{Int}}()
            end

            # Get the non-changing component of the edge
            isvert = first(Tuple(d)) != 0
            a = isvert ? vert(j) : horiz(j)
            if !haskey(D[d], a)
                D[d][a] = Set()
            end

            # Finally add the changing component of the edge
            b = isvert ? horiz(j) : vert(j)
            push!(D[d][a], b)
        end
    end

    # Now that we have information grouped by position of edges,
    # we should be able to count the adjacent edges
    return sum(values(D)) do D′
        sum(values(D′)) do s
            count_adjacent(s)
        end
    end
end

# For each group of object, add its area multiplied by the number of
# sides it has
function part2(data::Matrix{Char})
    D = areas(data)
    return sum(values(D)) do S
        sum(segments(S)) do s
            area(s) * sides(s)
        end
    end
end


### Main ###

function main()
    data = parse_input("data12.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1363484
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 838988
    println("Part 2: $part2_solution")
end

main()
