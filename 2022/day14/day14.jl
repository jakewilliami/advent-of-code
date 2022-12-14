# On each line of the puzzle input, we are given a list of (x, y) coordinates separated by
# arrows.  Each of these coordinates represent the start and end of a range of rocks in a
# cave.  The puzzle states that at a specified coordinate, sand is flowing into the cave,
# and we are to model the falling sand given various constraints.  Sand will fall down if it
# can (i.e., if no rocks or other sand is obstructing it), otherwise, it will try moving to
# the bottom left, otherwise, the bottom right.  If it can't do any of that, it will stop
# flowing and become sand at rest.
#
# In part one, we are to model the falling sand until it is falling out of the map.  The
# result is the number of sand "units" that falls while this is happening.
#
# Part two states that there is an infinte floor of the cave, and we are to model the
# falling sand until it stops flowing (again, counting the number of units this takes
# for stability).
#
# In this puzzle, I once again make use of Julia's CartesianIndex, and CartesianIndices (to
# represent the ranges from our puzzle input).  Instead of modelling a potentially large
# matrix, I opted to use a dictionary whose keys were coordinates.


### Parse input

const RockRange = CartesianIndices{2, NTuple{2, UnitRange{Int}}}
const RockRanges = Vector{RockRange}


function parse_input(data_file::String)
    data = RockRanges[]

    # Each line represents a range of rocks
    for line in readlines(data_file)
        C = CartesianIndex{2}[]

        # For each node in range
        for p in split(line, " -> ")
            a_str, b_str = reverse(split(p, ","))
            a, b = parse(Int, a_str), parse(Int, b_str)
            push!(C, CartesianIndex(a, b))
        end

        R = RockRange[]

        # For each pair in the nodes of ranges, construct an edge
        # That is, construct a UnitRange from Cartesian indices
        for i = 2:length(C)
            j, k = C[i - 1], C[i]
            r = j < k ? (j:k) : (k:j)
            push!(R, r)
        end

        # Add list of rock ranges to data
        push!(data, R)
    end

    return data
end


@enum CaveFeature rock sand_source sand_flowing sand_rest space

const CaveMap = Dict{CartesianIndex{2}, CaveFeature}

const SAND_SRC = CartesianIndex(0, 500)


function construct_cave_map(data::Vector{RockRanges})
    D = CaveMap(SAND_SRC => sand_source)

    # Fill in the rocks in our cave map
    for rock_ranges in data
        for rock_range in rock_ranges
            setindex!.(Ref(D), rock, rock_range)
        end
    end

    return D
end


### Part 1

# If the index i doesn't exist in the cave map, or is empty space,
# sand is allowed to flow there
valid_sand_pos(i::CartesianIndex{2}, D::CaveMap) = !haskey(D, i) || D[i] == space


# Model one iteration of flowing sand, based on the rules we were given
function _flow!(i::CartesianIndex{2}, D::CaveMap)
    # Try offsets in the following order: down, bottom left, bottom right
    for d in (CartesianIndex(1, 0), CartesianIndex(1, -1), CartesianIndex(1, 1))
        j = i + d
        if valid_sand_pos(j, D)
            D[j] = sand_flowing
            return j
        end
    end

    # If none of the other positions are valid, the sand is at rest
    D[i] = sand_rest
    return i
end


# Modify the state of the cave map until the current unit of sand is at rest
function flow!(i::CartesianIndex{2}, D::CaveMap)
    while true
        j = i
        i = _flow!(i, D)

        # If the sand is at rest, we are done
        if D[i] == sand_rest
            return i
        else
            # Otherwise, change the previous sand position into empty space
            D[j] = space
        end
    end
end


# The cave height is the largest y (row) coordinate in the map
# This function assumes the map has been initialised with all rocks
cave_height(D::CaveMap) = maximum(first(Tuple(i)) for i in keys(D))


function sand_will_fall_into_abyss(D::CaveMap, height::Int)
    D = deepcopy(D)
    i, c = SAND_SRC, 0

    # Sand will always go down unless at rest, so we can just count if the
    # sand has flowed more than the height of the cave
    while D[i] != sand_rest
        i = _flow!(i, D)
        c += 1

        # If the number of positions the sand has fallen is greater than the
        # total height of the cave, the sand is falling into the abyss!
        if c > height
            return true
        end
    end

    return false
end


function part1(data::Vector{RockRanges})
    D = construct_cave_map(data)
    h = cave_height(D)

    res = 0

    # Fill up the cave until sand is flowing into the abyss
    while !sand_will_fall_into_abyss(D, h)
        flow!(SAND_SRC, D)
        res += 1
    end

    return res
end


### Part 2

x_bounds(D::CaveMap) = extrema(last(Tuple(i)) for i in keys(D))


function part2(data::Vector{RockRanges})
    D = construct_cave_map(data)
    h = cave_height(D)

    # Make floor (floor level is 2 more than the height of the cave)
    x1, x2 = x_bounds(D)
    setindex!.(Ref(D), rock, CartesianIndex(h + 2, x1 - h):CartesianIndex(h + 2, x2 + h))

    # Let sand flow all across the floor, until full
    res = 0
    i = CartesianIndex{2}()
    while i != SAND_SRC
        i = flow!(SAND_SRC, D)
        res += 1
    end

    return res
end


### Main

function main()
    data = parse_input("data14.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1298
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 25585
    println("Part 2: $part2_solution")
end

main()
