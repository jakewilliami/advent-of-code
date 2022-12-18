# This was a fun problem!  We were given a bunch of ℝ³ coordinates to parse; each of those
# representing a 1×1×1 unit of lava.
#
# In part 1, we were asked to found the "surface area", as it were, for the points give;
# that is, count the number of edges for the points we were given that are exposed (don't
# have any connecting points).  I immediately understood how to solve this nice, simple
# problem; construct an array of these points, iterate over the points we were given, and
# for each point, check its surrounding indices.  Unfortunately it took me 30 minutes to
# complete part 1, but 20 minutes of that was debugging the cardinal_directions function
# from my own package >:(
#
# Part 2 was interesting; we had to get the _outer_ surface area of the structure—so even if
#  there were exposed bits, we would have to verify that they were on the outside of the
# structure, rather than the inside.  I initially thought I would be clever and define the
# following: any given coordinate that is empty in the array is internal if there are filled
# points in all cardinal directions from it.  I got the answer 2003 using this method, but
# it wasn't correct.  hen ensued about 4 hours of debugging (see 47a21ae)...  The real
# answer for me was 2008.  The problem with this is that there were edge cases such as this:
#   ###
#   #.#
#   ..#
#   ###
# The empty space in on the second line is actually external, however based on my
# definition, this would be internal.  It was clear to me then that I had to figure out how
# to essentially "flood fill" the empty space to see if it reaches the outside.  I did get a
# bit of inspiration fro another's answer when trying to implement this.


using AdventOfCode.Multidimensional

using DataStructures
using MultidimensionalTools: extrema_indices


### Parse input

function parse_input(data_file::String)
    N = 3  # three-dimensional points
    data = CartesianIndex{N}[]

    for line in eachline(data_file)
        coords = parse.(Int, split(line, ','))
        i = CartesianIndex(Tuple(coords)) + CartesianIndex{N}()
        push!(data, i)
    end

    return data
end


### Part 1

function construct_point_matrix(data::Vector{CartesianIndex{N}}) where {N}
    # Construct a matrix of the size of the extrema indices
    extrema_dims = extrema_indices(Tuple.(data))
    sz = Tuple(last(Tuple(i)) for i in extrema_dims)
    M = zeros(Bool, sz)
    # Fill in the data
    setindex!.(Ref(M), true, data)
    return M
end


function part1(data::Vector{CartesianIndex{N}}) where {N}
    M = construct_point_matrix(data)
    res = 0

    for i in data
        # Check each cardinal adjacency
        for d in cardinal_directions(ndims(M))
            j = i + d

            # If this adjacent value is on the edge (i.e., its coordinate does not exist in
            # the matrix), or is is not filled, then it is exposed to air (and thus counts
            # towards the surface area of the structure)
            if (!hasindex(M, j) || !M[j])
                res += 1
            end
        end
    end

    return res
end


### Part 2

function is_external(
    i::CartesianIndex{N},
    points::Vector{CartesianIndex{N}},
    in_points::Set{CartesianIndex{N}} = Set{CartesianIndex{N}}(),
    out_points::Set{CartesianIndex{N}} = Set{CartesianIndex{N}}(),
) where {N}

    # If the result has been memoised, return immediately
    i ∈ in_points && return false
    i ∈ out_points && return true

    # Otherwise, we need to start looking at each adjacent point
    seen_points = Set{CartesianIndex{N}}()
    Q = Queue{CartesianIndex{N}}()
    enqueue!(Q, i)

    while !isempty(Q)
        j = dequeue!(Q)

        # Skip this index if it is part of the structure, or if we have already processed it
        j ∈ points && continue
        j ∈ seen_points && continue

        push!(seen_points, j)

        # If we have seen sufficiently many points, we can safely say that they are not part
        # of the structure, so must be external
        if length(seen_points) > 2length(points)
            for p in seen_points
                push!(out_points, p)
            end
            return true
        end

        for d in cardinal_directions(N)
            enqueue!(Q, j + d)
        end
    end

    for p in seen_points
        push!(in_points, p)
    end
    return false
end


function part2(data::Vector{CartesianIndex{N}}) where {N}
    # Memoise internal and external points to reduce computation time
    in_points, out_points = Set{CartesianIndex{N}}(), Set{CartesianIndex{N}}()

    res = 0
    for i in data, d in cardinal_directions(N)
        if is_external(i + d, data, in_points, out_points)
            res += 1
        end
    end

    return res
end


### Main

function main()
    data = parse_input("data18.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 3498
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 2008
    println("Part 2: $part2_solution")
end

main()
