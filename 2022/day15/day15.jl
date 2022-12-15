# This was a really interesting problem today.  Our input are a list of sensors and
# associated beacons; each sensor tells us its position, and the position of the closest
# beacon to it.  From this information, we can deduce that all space closer in distance
# (measured using the Manhattan distance) to the sensor than its closest beacon must not
# have a beacon.  The ultimate goal is to find a beacon whose coordinates we do not have,
# but analysing the negative space of the location, using the above logical deduction.
#
# Part one got us to find, for a given y coordinate, the number of spaces in which a beacon
# cannot be present (based on the above logic).  I implemented this by iterating over a
# reasonable x range, and for the given y coordinate, increment the result if the current
# coordinate is within the Manhattan distance of the associated beacon for any one of our
# sensors.
#
# Part two was a little more tricky to implement.  The way I went about it was to, for each
# sensor, construct a set of points representing the line at the radius from the sensor at
# the Manhattan distance of the closest beacon.  I figured that beacon we are searching for
# is only just (i.e., within a couple of indices) out of the range of any of our radii.
#
# Throughout this day, I struggled a little with optimisation challenges.  Initially I
# thought to represent these data in a dictionary, however this got expensive with the real
# input.  I then found a nice enough solution for part 1, as clever `break`ing from loops
# means that I never have to keep track of the indices we have already checked.  I also
# considered using a sparse array, but didn't end up using it.  Part 2 was even more tricky,
# and I have not yet found a good solution for it.  There is certainly some optimisation to
# be implemented for my part 2 solution, as I think it checks some indices multiple times.


using AdventOfCode.Multidimensional


### Parse input

function parse_input(data_file::String)
    re = r"Sensor at x=(\-?\d+), y=(\-?\d+): closest beacon is at x=(\-?\d+), y=(\-?\d+)"
    data = NTuple{2, CartesianIndex{2}}[]
    for line in eachline(data_file)
        xs_str, ys_str, xb_str, yb_str = match(re, line).captures
        xs, ys, xb, yb = parse.(Int, (xs_str, ys_str, xb_str, yb_str))
        push!(data, (CartesianIndex(ys, xs), CartesianIndex(yb, xb)))
    end

    return data
end


### Part 1

# Calculate the Manhattan distance of two points
# https://www.wikiwand.com/en/Taxicab_geometry
md(i::CartesianIndex{2}, j::CartesianIndex{2}) = sum(map(abs, Tuple(i - j)))


get_x_bounds(S::Set{CartesianIndex{2}}) = extrema(last(Tuple(i)) for i in S)


function part1(data::Vector{NTuple{2, CartesianIndex{2}}})
    R = 2_000_000

    sensors = Set{CartesianIndex{2}}(s for (s, _b) in data)
    beacons = Set{CartesianIndex{2}}(b for (_s, b) in data)

    # Precompute Manhattan distances between sensors and associated
    # beacons, in the interest of efficiency
    D = Dict{CartesianIndex{2}, Int}()
    for (sᵢ, bᵢ) in data
        v = md(bᵢ, sᵢ)
        D[sᵢ] = v
    end

    x_min, x_max = get_x_bounds(beacons)

    # Iterate over a reasonable x range, and for the selected y
    # coordinate (R), increment result if the current coordinate
    # is in the range of any of our sensors
    m = maximum(d for (_sᵢ, d) in D) + 1
    res = 0
    xᵢ = x_min - m
    while xᵢ <= (x_max + m)
        i = CartesianIndex(R, xᵢ)
        for sᵢ in sensors
            v = D[sᵢ]
            u = md(i, sᵢ)
            if u <= v && i ∉ sensors && i ∉ beacons
                res += 1
                break
            end
        end
        xᵢ += 1
    end

    return res
end


### Part 2

get_y_bounds(beacons::Set{CartesianIndex{2}}) = extrema(first(Tuple(i)) for i in beacons)


# Calculate the "tuning frequency" of a given index
tf(i::CartesianIndex{2}) = sum(Tuple(i) .* (1, 4_000_000))


# Check if a beacon index is allowed based on the problem's constraints
beacon_index_allowed(i::CartesianIndex{N}, min_coord::Int, max_coord::Int) where {N} =
    all(min_coord ≤ k ≤ max_coord for k in Tuple(i))


# Construct a set of indices creating the diagonal line between two points,
# a and b, inclusive.
function diag_line(a::CartesianIndex{2}, b::CartesianIndex{2})
    d = direction(b - a)
    line = Set{CartesianIndex{2}}()
    push!(line, a)

    i = a
    while i != b
        i += d
        push!(line, i)
    end

    return line
end


# https://www.wikiwand.com/en/Bresenham's_line_algorithm
# An alternative to the above diag_line method.  Similar performance.
# This is the line algorithm for octant zero.  As the Manhattan
# distance is not complex, the radius will always be a diamond
# around the point, and so this is sufficient (as gradient is
# always one).  Note that, compared to diag_line, order matters!
function diag_line_alt(a::CartesianIndex{2}, b::CartesianIndex{2})
    y0, x0 = Tuple(a)
    y1, x1 = Tuple(b)
    dx = x1 - x0
    dy = y1 - y0
    D = 2dy - dx
    y = y0

    S = Set{CartesianIndex{2}}()
    for x in x0:x1
        push!(S, CartesianIndex(y, x))
        if D > 0
            y += 1
            D -= 2dx
        end
        D += 2dy
    end

    return S
end


# Given a point i, and a radius, will return the points around the
# edge of the radius as defined by the Manhattan distance
function get_md_radius(i::CartesianIndex{2}, r::Int)
    S = Set{CartesianIndex{2}}()
    bounds = Tuple(i + r * d for d in cardinal_directions(2))
    for k in 2:4
        R = diag_line(bounds[k - 1], bounds[k])
        for p in R
            push!(S, p)
        end
    end

    return S
end


# Given a radius of points, will expand that radius by one, returning
# the new points at the radius
function get_outer_radius(R::Set{CartesianIndex{2}})
    R′ = Set{CartesianIndex{2}}()
    directions = cartesian_directions(2)
    for i in R
        for d in directions
            j = i + d
            if j ∉ R
                push!(R′, j)
            end
        end
    end
    return R′
end


function part2(data::Vector{NTuple{2, CartesianIndex{2}}})
    min_coord, max_coord = 0, 4_000_000

    sensors = Set{CartesianIndex{2}}(s for (s, _b) in data)
    beacons = Set{CartesianIndex{2}}(b for (_s, b) in data)

    # Precompute Manhattan distances between sensors and beacons
    D = Dict{CartesianIndex{2}, Int}()
    for (sᵢ, bᵢ) in data
        v = md(bᵢ, sᵢ)
        D[sᵢ] = v
    end

    x_min, x_max = get_x_bounds(beacons)
    y_min, y_max = get_y_bounds(beacons)
    m = maximum(d for (_sᵢ, d) in D) + 1

    S = Set{CartesianIndex{2}}()

    # For each sensor, get a small radius (a couple of indices thick)
    # and search for our missing beacon on the perimiter of our sensors'
    # Manhattan distance to their closest beacons.  This is almost certainly
    # not the most optimal solution, but just something I thought of.
    for (sᵢ, bᵢ) in data
        v = md(sᵢ, bᵢ)
        R = get_md_radius(sᵢ, v)
        R′ = get_outer_radius(R)
        for p in R ∪ R′
            d = direction(p - sᵢ)
            i = p + d
            i ∈ sensors && continue
            i ∈ beacons && continue
            beacon_index_allowed(i, min_coord, max_coord) || continue
            # Check if the current index has a Manhattan distance greater
            # than the distance to the closest beacon for each sensor.
            # If this is false, then this index cannot be a beacon.
            all(md(i, sⱼ) > sᵥ for (sⱼ, sᵥ) in D) || continue
            return tf(i)
        end
    end
end


### Main

function main()
    data = parse_input("data15.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 5127797
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 12518502636475
    println("Part 2: $part2_solution")
end

main()
