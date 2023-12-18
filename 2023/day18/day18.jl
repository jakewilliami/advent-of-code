# Initially tried simulating but had some trouble with offsets, so did some research and found a couple of nice algorithms to use

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools

D = Dict('U' => INDEX_UP, 'D' => INDEX_DOWN, 'R' => INDEX_RIGHT, 'L' => INDEX_LEFT)

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = split.(strip.(readlines(input_file)))
    L2 = []
    for l in L
        a, b, c = l
        a = D[only(a)]
        b = parse(Int, b)
        c = c[2:end-1]
        c = c[2:end]
        # c = hex2bytes(c)
        push!(L2, (a, b, c))
    end
    # L = get_integers.(L)
    return L2
end

function extrema_indices(I::Union{Vector{NTuple{N, Int}}, Vector{CartesianIndex{N}}}) where N
    return CartesianIndex.(extrema(reduce(vcat, permutedims(collect(Tuple(i))) for i in I), dims = 1))
end

function append_n_times(M::Array{T, N}, n::Int, fill_elem::T; dims::Int = 1) where {T, N}
    sz = ntuple(d -> ifelse(d == dims, n, size(M, d)), max(N, dims))
    return cat(M, fill(fill_elem, sz); dims = dims)
end

function append_n_times_backwards(M::Array{T, N}, n::Int, fill_elem::T; dims::Int = 1) where {T, N}
    sz = ntuple(d -> ifelse(d == dims, n, size(M, d)), max(N, dims))
    return cat(fill(fill_elem, sz), M; dims = dims)
end

function reshape_as_required(M::Array{T, N}, expand_by::T, inds::Union{Vector{NTuple{N, Int}}, Vector{CartesianIndex{N}}}) where {T, N}
    indices = Vector{Union{T, Nothing}}()
    ind_extrema = extrema_indices(inds)

    for d in 1:ndims(M)
        ith_extrema = Tuple(ind_extrema[d])
        if !all(map(m -> m ≤ size(M, d), ith_extrema))
            for invalid_idx in filter(i -> i > size(M, i) || i < 1, ith_extrema)
                difference = invalid_idx - size(M, d)
                M = ifelse(sign(difference) == 1, append_n_times(M, abs(difference), expand_by, dims = d), append_n_times_backwards(M, abs(difference), expand_by, dims = d))
            end
        end
    end

    return M
end

function is_external(
    i, points, in_points, out_points
)

    # If the result has been memoised, return immediately
    i ∈ in_points && return false
    i ∈ out_points && return true

    # Otherwise, we need to start looking at each adjacent point
    seen_points = Set()
    Q = Queue{CartesianIndex{2}}()
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

        for d in cardinal_directions(2)
            enqueue!(Q, j + d)
        end
    end

    for p in seen_points
        push!(in_points, p)
    end
    return false
end

function dis(M)
    println(join((join(row) for row in eachrow(M)), '\n'))
end

function flood_fill!(grid, i, target_color, new_color, seen = Set())
    hasindex(grid, i) || return
    i in seen && return
    push!(seen, i)

    if grid[i] != target_color
        return
    end

    grid[i] = new_color

    # Explore neighbors
    for d in cardinal_directions(2)
        flood_fill!(grid, i + d, target_color, new_color, seen)
    end
end

function _get_trench_indices(data)
    i = CartesianIndex{2}()
    I = [i]
    for (d, n, _c) in data
        i += (d*n)
        push!(I, i)
    end
    return I
end

function get_trench_indices(data)
    i = origin(2)
    I = []

    for (d, n, _c) in data
        # i += d
        for _ in 0:n-1
            push!(I, i)
            i += d
        end
    end
    println(length(I))
    return I

    for (d, n, _c) in data
        for k in 0:n
            j = i + (d * k)
            push!(I, j)
        end
    end

    return I


    for (d, n, _c) in data
        push!(I, i)
        for k in 1:n
            j = i + (d * k)
            push!(I, j)
        end
        i = (d * n)
    end
    return (I)
end

function get_bounds(data)
    I = get_trench_indices(data)
    return extrema_indices(I)
end

function polygon_area(I)
    area = 0
    for i in 1:(length(I) - 1)
        y1, x1 = I[i].I
        y2, x2 = I[i + 1].I
        # println(I[i].I, " ", I[i + 1].I, " -> ", x1 * y2, " - ", x2 * y1, " = ", x1 * y2 - x2 * y1, " -> ", area + x1 * y2 - x2 * y1)
        a = x1 * y2
        b = x2 * y1
        # area += a - b
        area += b - a
        # area += x1 * y2 - x2 * y1
    end
    println(area)
    return abs(area) ÷ 2

    # Shoelace formula
    # https://www.wikiwand.com/en/Shoelace_formula
    # https://www.wikiwand.com/en/Shoelace_formula#Triangle_formula
    area = 0
    for i in 1:(length(I) - 1)
        a, b = I[i], I[i + 1]
        # println(a, b)
        (y1, x1), (y2, x2) = a.I, b.I
        area += x1 * y2 - x2 * y1
    end
    # println(area)
    area = area ÷ 2
    return area
end

function positive_polygon_area(I)
    area = polygon_area(I)
    return area
    area >= 0 && return area
    # if the vertices were not given in counter-clockwise order,
    # the result will be negative, so reverse and try again
    return polygon_area(reverse(I))
end

function points_inside_polygon(area, I)
    # 38 84 42 19
    # print(len(borders), abs(area), abs(area) // 2, perimeter // 2)
    println("$(length(I)) $(abs(area)) $(length(I) ÷ 2) $(area - length(I) ÷ 2 + 1)")
    perimeter = length(I)
    interior_area = area - perimeter ÷ 2 + 1
    return interior_area
    interior_area = area - length(I)  ÷ 2 + 1
    return interior_area
end

function trench_area(data)
    I = get_trench_indices(data)

    area = positive_polygon_area(I)
    points = points_inside_polygon(area, I)

    return length(I) + points
end

function part1(data)
    return trench_area(data)

    I = get_trench_indices(data)

    # Shoelace formula
    # https://www.wikiwand.com/en/Shoelace_formula
    # https://www.wikiwand.com/en/Shoelace_formula#Triangle_formula
    area = 0
    for i in 1:(length(I) - 1)
        a, b = I[i], I[i + 1]
        # println(a, b)
        (y1, x1), (y2, x2) = a.I, b.I
        area += x1 * y2 - x2 * y1
    end
    area = area ÷ 2

    # Pick's theorem to compute the inner points of a grid-based polygon
    # https://en.wikipedia.org/wiki/Pick%27s_theorem
    interior_area = area - length(I)  ÷ 2 + 1
    return interior_area + length(I)


    # println(get_bounds(data))
    # M = fill('.', 1, 1)
    M = reshape_as_required(fill('.', 1, 1), '.', reshape(get_bounds(data), :))

    println(size(M))
    # reshape_as_required(M::Array{T, N}, expand_by::T, inds::Union{Vector{NTuple{N, Int}}, Vector{CartesianIndex{N}}})
    i = only(CartesianIndices(M))
    for (d, n, c) in data
        # println(d, n, c)
        oi = i
        # os = size(M)
        i += (d * n)
        # M = reshape_as_required(M, '.', [i])
        # ns = size(M)

        println("============")
        println(size(M),d,i)
        # println("============")
        for k in 0:(n-1)
            off = CartesianIndex(ns .- os)
            j = (oi) + (d * k) # - CartesianIndex{2}()
            println(j)
            M[j] = '#'
        end
    end

    # dis(M)

    in_points, out_points = Set(), Set()
    points = [i for i in CartesianIndices(M) if M[i] == '#']

    res = Set()
    for i in CartesianIndices(M), d in cardinal_directions(2)
        if !is_external(i+d, points, in_points, out_points)
            hasindex(M, i+d) || continue
            push!(res, i+d)
            # res += 1
        end
    end
    # M2 = fill('.', size(M))
    # for i in res
        # M2[i] = '#'
    # end
    # println()
    # dis(M2)
    return length(res)
    # println()
    # flood_fill!(M, CartesianIndex{2}(), '#', '#')
    # dis(M)
end

function part2(data)
    # Each hexadecimal code is six hexadecimal digits long. The first five hexadecimal digits encode the distance in meters as a five-digit hexadecimal number. The last hexadecimal digit encodes the direction to dig: 0 means R, 1 means D, 2 means L, and 3 means U.
    Ds = Dict('0' => INDEX_RIGHT, '1' => INDEX_DOWN, '2' => INDEX_LEFT, '3' => INDEX_UP)
    data = [(Ds[c[end]], parse(Int, c[1:end-1], base=16), c) for (d, n, c) in data]
    return trench_area(data)
end

function main()
    data = parse_input("data18.txt")
    # data = parse_input("data18.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 62500
    println("Part 1: $part1_solution")
    # not 1790
    # not 206

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
    # not 952408144115: too low
end

main()
