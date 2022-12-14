function parse_input(data_file::String)
    data = []

    for line in readlines(data_file)
        C = []
        for p in split(line, " -> ")
            a_str, b_str = reverse(split(p, ","))
            a, b = parse.(Int, (a_str, b_str))
            push!(C, CartesianIndex(a, b))
        end
        # C = [CartesianIndex(parse.(Int, reverse(split(p, ",")))...) for p in ps]
        R = []
        # println(C)
        for i in 2:length(C)
            j, k = C[i - 1], C[i]
            r = j < k ? (j:k) : (k:j)
            push!(R, r)
        end
        push!(data, R)
    end

    return data
end

function find_bounds(rocks)
    rocks = Base.Iterators.flatten(rocks)
    x2 = maximum(first(Tuple(i)) for i in rocks)
    x1 = minimum(first(Tuple(i)) for i in rocks)
    y2 = maximum(last(Tuple(i)) for i in rocks)
    y1 = minimum(last(Tuple(i)) for i in rocks)
    return CartesianIndex(x1, y1):CartesianIndex(x1, y2)
    # return CartesianIndex(x1, y1), CartesianIndex(x2, y2)
end

@enum Terrain rock sand_source sand_flowing sand_rest space

function _flow_pos(i::CartesianIndex{2}, D::Dict{CartesianIndex{2}, Terrain})
    # Try below
    j = i + CartesianIndex(1, 0)
    if !haskey(D, j) || D[j] == space
        # println("    Can move down a D has no $j: $(get(D, j, nothing))")
        return j
    end

    # Try bottom left
    j = i + CartesianIndex(1, -1)
    if !haskey(D, j) || D[j] == space
        # println("    Can move down left a D has no $j")
        return j
    end

    # Try bottom right
    j = i + CartesianIndex(1, 1)
    if !haskey(D, j) || D[j] == space
        # println("    Can move down right a D has no $j")
        return j
    end

    return nothing
end

function _flow!(i::CartesianIndex{2}, D::Dict{CartesianIndex{2}, Terrain})
    j = _flow_pos(i, D)
    # println("Moving $i to $j")

    if !isnothing(j)
        D[j] = sand_flowing
        return j
    end

    # Otherwise, sand at rest
    D[i] = sand_rest
    return i
end

function flow!(i::CartesianIndex{2}, D::Dict{CartesianIndex{2}, Terrain})
    # Modify the state of all flowing sand
    # Next unit of sand is not produced until the previous has come to rest
    while D[i] != sand_rest
        j = i
        i = _flow!(i, D)
        if D[i] != sand_rest
            D[j] = space
        end
    end
    return i

    # INGORE ME
    for (i, t) in D
        t == sand_flowing || continue
        flow!(i, D)
        D[i] = space
    end
end

function find_the_botty(rocks)
    rocks = Base.Iterators.flatten(rocks)
    c2 = maximum(first(Tuple(i)) for i in rocks)
    c1 = minimum(first(Tuple(i)) for i in rocks)
    r2 = maximum(last(Tuple(i)) for i in rocks)
    r1 = minimum(last(Tuple(i)) for i in rocks)

    return CartesianIndex(r2, c1):CartesianIndex(r2, c2)
end

function find_height(rocks)
    # rocks = Base.Iterators.flatten(rocks)
    h = 0
    for rock_ranges in rocks
        for rock_range in rock_ranges
            for rock_i in rock_range
                h′ = first(Tuple(rock_i))
                if h′ > h
                    h = h′
                end
            end
        end
    end
    return h + 1
    println(collect(rocks))
    return maximum(last(Tuple(i)) for i in rocks) + 1
end

# botty::CartesianIndices{2, Tuple{UnitRange{Int64}, UnitRange{Int64}}}
function sand_will_fall_into_abyss(D::Dict{CartesianIndex{2}, Terrain}, height, src::CartesianIndex{2})
    # Sand will always go down unless at rest, so we can just count if the
    # sand has flowed more than the height
    D = deepcopy(D)
    c = 1
    i = src
    # TODO: check if i needs to be set _below_ src
    # while first(Tuple(i)) < first(Tuple(first(botty))) && last(Tuple(i)) < last(Tuple(last(botty)))
    # println(height)
    while D[i] != sand_rest
        # i = flow!(i, D)
        i = _flow!(i, D)
        # println(c, " ", c <= height)
        c += 1
        if c > height
            # println(D)
            return true
        end
    end

    # if c > height
        # return true
    # end

    @assert D[i] == sand_rest
    return false
end

function main(data)
    # max_, min_ = find_bounds(data)
    src = CartesianIndex(0, 500)
    # Construct initial state
    D = Dict{CartesianIndex{2}, Terrain}(src => sand_source)
    for rock_ranges in data
        for rock_range in rock_ranges
            # println(rock_range)
            for rock_i in rock_range
                D[rock_i] = rock
            end
        end
    end


    H = find_height(data)
    # println(D)
    # return sand_will_fall_into_abyss(D, H, src)
    res = 0
    while !sand_will_fall_into_abyss(D, H, src)
        _i = flow!(src, D)
        res += 1
    end
    return res
    return find_height(data)
    return find_the_botty(data)

    # Make sand flow

    while true

    end
end

# println(main(data))
part1(data) = main(data)


function main2(data)
    # max_, min_ = find_bounds(data)
    src = CartesianIndex(0, 500)
    # Construct initial state
    D = Dict{CartesianIndex{2}, Terrain}(src => sand_source)
    for rock_ranges in data
        for rock_range in rock_ranges
            # println(rock_range)
            for rock_i in rock_range
                D[rock_i] = rock
            end
        end
    end

    H = find_height(data)

    # Make floor
    for i in -1000:1000
        D[CartesianIndex(H + 1, i)] = rock
    end

    # Let sand flow
    res = 0
    # i = src
    i = CartesianIndex(0)
    # while get(D, i, space) != sand_rest
    while i != src
        i = flow!(src, D)
        # while D[i] != sand_rest
            # j = i
            # i = _flow!(i, D)
            # if D[i] != sand_rest
                # D[j] = space
            # end
        # end
        res += 1
    end
    return res
end

# println(main2(data))
part2(data) = main2(data)


function main()
    data = parse_input("data13.txt")

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
