using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function are_inline(d::CartesianIndex{N}, a1::CartesianIndex{N}, a2::CartesianIndex{N}, data) where {N}
    a1 += d
    while hasindex(data, a1)
        # println("!! ",a1, ", ", a2, " with direction $d")
        a1 == a2 && return true
        a1 += d
    end
    return false
end

function are_inline(a1::CartesianIndex{N}, a2::CartesianIndex{N}, data) where {N}
    # println("Checking if $a1 and $a2 are inline")
    for d in cartesian_directions(N)
        are_inline(d, a1, a2, data) && return true, d
    end
    return false, 𝟘(N)
end

isfrequency(c) = isuppercase(c) || islowercase(c) || c ∈ '0':'9'

function antenae_indices(data)
    A = []
    for i in CartesianIndices(data)
        c = data[i]
        if isfrequency(c)
            # println(i)
            push!(A, i)
        end
    end
    # println("================")
    return A
end

function antinode_indices(a1::CartesianIndex{N}, a2::CartesianIndex{N}, d::CartesianIndex{N}, data) where {N}
    o1, o2 = a1, a2
    if (a1 + d - a2) < (a1 - d - a2)
        d = opposite_direction(d)
    end

    A = Set()
    a1 += d

    while hasindex(data, a1) && length(A) < 1
        if isfrequency(data[a1])
            a1 += d
            continue
        end
        if !acceptable_distance(a1, o1, o2)
            a1 += d
            continue
        end
        push!(A, a1)
    end

    d = opposite_direction(d)
    a2 += d
    while hasindex(data, a2) && length(A) < 2
        if isfrequency(data[a2])
            a2 += d
            continue
        end
        if !acceptable_distance(a2, o1, o2)
            a2 += d
            continue
        end
        push!(A, a2)
    end

    A
end

# "In particular, an antinode occurs at any point that is perfectly in line with two antennas of the same frequency - but only when one of the antennas is twice as far away as the other. This means that for any pair of antennas with the same frequency, there are two antinodes, one on either side of them."
#
# I misunderstood the problem a couple of times

#
# ERROR getting points that extrapolate...and i only went in 8 defined directions not weird gradients

function part1(data)
    AN = Set()
    A = antenae_indices(data)
    for i in 1:length(A)
        ai = A[i]
        for j in (i+1):length(A)
            aj = A[j]
            println("Checking data[$ai] ($(data[ai])) and data[$aj] ($(data[aj]))")
            data[ai] == data[aj] || continue
            inline, d = are_inline(ai, aj, data)
            println("$ai $aj, $inline, $d")
            if inline
                for ak in antinode_indices(ai, aj, d, data)
                    push!(AN, ak)
                end
            end
        end
    end
    return length(AN)
end

using GeoStats, LinearAlgebra

between(a, b, p) = 0 <= dot((b - a) / norm(b - a), (p - a) / norm(b - a)) <= 1

function points_on_line(x, y, data)
    # https://discourse.julialang.org/t/105896/2
    A = Set()
    for i in CartesianIndices(data)
        (i == x || i == y) && continue
        if Point(i.I...) ∈ Segment(x.I, y.I)
        # if between(x.I, y.I, i.I)
            push!(A, i)
        end
    end
    A
end

# https://en.wikipedia.org/wiki/Bresenham's_line_algorithm
#=
plotLineLow(x0, y0, x1, y1)
    dx = x1 - x0
    dy = y1 - y0
    yi = 1
    if dy < 0
        yi = -1
        dy = -dy
    end if
    D = (2 * dy) - dx
    y = y0

    for x from x0 to x1
        plot(x, y)
        if D > 0
            y = y + yi
            D = D + (2 * (dy - dx))
        else
            D = D + 2*dy
        end if
=#
function points_on_line_low(x, y, data)
    y0, x0 = Tuple(x)
    y1, x1 = Tuple(y)
    δx = x1 - x0
    δy = y1 - y0
    yi = 1
    if δy < 0
        yi = -1
        δy *= -1
    end
    Δ = 2δy - δx
    y = y0

    points = Set()
    for x in x0:x1
        push!(points, CartesianIndex(y, x))
        if Δ > 0
            y += yi
            Δ += 2(δy - δx)
        else
            Δ += 2δy
        end
    end
    points
end

#=
plotLineHigh(x0, y0, x1, y1)
    dx = x1 - x0
    dy = y1 - y0
    xi = 1
    if dx < 0
        xi = -1
        dx = -dx
    end if
    D = (2 * dx) - dy
    x = x0

    for y from y0 to y1
        plot(x, y)
        if D > 0
            x = x + xi
            D = D + (2 * (dx - dy))
        else
            D = D + 2*dx
        end if
=#
function points_on_line_high(x, y, data)
    y0, x0 = Tuple(x)
    y1, x1 = Tuple(y)
    δx = x1 - x0
    δy = y1 - y0
    xi = 1
    if δx < 0
        xi *= -1
        δx *= -1
    end
    Δ = 2δx - δy
    x = x0

    points = Set()
    for y in y0:y1
        push!(points, CartesianIndex(y, x))
        if Δ > 0
            x += xi
            Δ + 2(δx - δy)
        else
            Δ += 2δx
        end
    end

    return points
end

function gradient(x, y)
    δy, δx = abs.(Tuple(x - y))
    δy / δx
end

function points_on_line(x, y, data)
    g = gradient(x, y)
    if -1 ≤ g ≤ 1
        return points_on_line_low(x, y, data)
    elseif abs(g) > 1
        return points_on_line_high(x, y, data)
    else
        error("Gradient $g unhandled")
    end
end

function points_on_line(x, y, data)
    y0, x0 = Tuple(x)
    y1, x1 = Tuple(y)
    nrows, ncols = size(data)
    points = Set()

    dx = x1 - x0
    dy = y1 - y0

    if abs(dx) > abs(dy)
        # Line is more horizontal
        for x in 1:ncols
            t = (x - x0) / dx
            y = y0 + t * dy
            if 1 ≤ y ≤ nrows
                if isinteger(y)
                    push!(points, CartesianIndex(round(Int, y), x))
                end
                # push!(points, CartesianIndex(round(Int, y), x))
            end
        end
    else
        # Line is more vertical
        for y in 1:nrows
            t = (y - y0) / dy
            x = x0 + t * dx
            if 1 ≤ x ≤ ncols
                if isinteger(x)
                    push!(points, CartesianIndex(y, round(Int, x)))
                end
                # push!(points, CartesianIndex(y, round(Int, x)))
            end
        end
    end

    return points
end

function part1(data)
    # A = similar(data)
    # for i in eachindex(A)
    #     A[i] = '.'
    # end
    # B = antenae_indices(data)
    # for i in B
    #     A[i] = 'a'
    # end
    # for i in 1:length(B)
    #     ai = B[i]
    #     for j in (i+1):length(B)
    #         aj = B[j]
    #         for k in points_on_line(ai, aj, A)
    #             A[k] = '#'
    #         end
    #     end
    # end
    # for row in eachrow(A)
    #     println(join(row))
    # end
    # return 0

    AN = Set()
    A = antenae_indices(data)
    for i in 1:length(A)
        ai = A[i]
        for j in (i+1):length(A)
            aj = A[j]
            data[ai] == data[aj] || continue
            println("$ai, $aj:")
            for k in points_on_line(ai, aj, data)
                # NEED TO ACCOUNT FOR OVERLAP: https://www.reddit.com/r/adventofcode/comments/1h9cz19/comment/m0zx3fi/
                # isfrequency(data[k]) && continue
                a = acceptable_distance(k, ai, aj)
                println("    $k, $a")
                if a
                    push!(AN, k)
                end
            end
        end
    end
    return length(AN)
end

using Distances

function dist(a1, a2)
    # COPY ERROR HARD CODING VECTORS
    Euclidean()(a1.I, a2.I)
end

function acceptable_distance(ani, a1, a2)
    # println("d($(Tuple(ani)), $(Tuple(a1))) = $(dist(ani, a1)); d($(Tuple(ani)), $(Tuple(a2))) = $(dist(ani, a2))")
    dist(ani, a1) ≈ 2dist(ani, a2) || dist(ani, a2) ≈ 2dist(ani, a1)
end

function are_freqs_inline_and_same(ani::CartesianIndex{N}, f1::CartesianIndex{N}, f2::CartesianIndex{N}, d::CartesianIndex{N}, data) where {N}
    A = Set()
    ani += d
    while hasindex(data, ani)
        if isempty(A)
            push!(A, ani)
        elseif all(data[i] == data[ani] for i in A)
            push!(A, ani)
        end
        ani += d
    end
    return length(A) > 1, A
end

function are_freqs_inline_and_same(ani::CartesianIndex{N}, f1::CartesianIndex{N}, f2::CartesianIndex{N}, data) where {N}
    A1 = Set()
    for d in cartesian_directions(N)
        inline, A = are_freqs_inline_and_same(ani, f1, f2, d, data)
        if inline
            push!(A1, A)
        end
    end
    return !isempty(A1), A1
end

function antinode_indices(ani, antenae, data)
    A = Set()
    for i in 1:length(antenae)
        ai = antenae[i]
        for j in (i + 1):length(antenae)
            aj = antenae[j]
            inline, A′ = are_freqs_inline_and_same(ani, ai, aj, data)
            println("$ani, $ai, $aj, $(acceptable_distance(ani, ai, aj))")
            if inline && acceptable_distance(ani, ai, aj)
                for a in A′
                    push!(A, i)
                end
            end
        end
    end
    return A
end

function part1′(data)
    AN = Set()
    A = antenae_indices(data)
    for i in CartesianIndices(data)
        V = antinode_indices(i, A, data)
        for ai in V
            push!(AN, ai)
        end
    end
    return length(AN)
end

function part2(data)
    A = similar(data)
    for i in eachindex(A)
        A[i] = '.'
    end
    B = antenae_indices(data)
    for i in B
        A[i] = 'a'
    end
    for i in 1:length(B)
        ai = B[i]
        for j in (i+1):length(B)
            aj = B[j]
            for k in points_on_line(ai, aj, A)
                A[k] = '#'
            end
        end
    end
    for row in eachrow(A)
        println(join(row))
    end
    # return 0
    AN = Set()
    A = antenae_indices(data)
    for i in 1:length(A)
        ai = A[i]
        for j in (i+1):length(A)
            aj = A[j]
            data[ai] == data[aj] || continue
            for k in points_on_line(ai, aj, data)
                push!(AN, k)
            end
        end
    end
    for a in sort(collect(AN))
        println(a)
    end
    return length(AN)
end

function main()
    data = parse_input("data08.txt")
    # data = parse_input("data08.test.txt")
    # data = parse_input("data08.test2.txt")
    # data = parse_input("data08.test3.txt")
    # data = parse_input("data08.test4.txt")
    # data = parse_input("data08.test5.txt")
    # data = parse_input("data08.test6.txt")

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()

# NOT 352, too low
