using AdventOfCode.Multidimensional

using DataStructures

f = "data15.txt"
# f = "test.txt"

# data = readlines(f)
data = []
for line in eachline(f)
    _, _, xstr, ystr, _, _, _, _, x2str, y2str = split(line)
    xstr, ystr, x2str, y2str = strip.(strip.(last.(split.((xstr, ystr, x2str, y2str), '=')), ','), ':')
    x, y, x1, y1 = parse.(Int, (xstr, ystr, x2str, y2str))
    push!(data, (CartesianIndex(y, x), CartesianIndex(y1, x1)))
end

# println(data)

@enum Tech sensor beacon no_beacon

function initialise_map(data)
    D = Dict{CartesianIndex{2}, Tech}()
    for (sᵢ, bᵢ) in data
        D[sᵢ] = sensor
        D[bᵢ] = beacon
    end
    return D
end

#=function is_further_away(S, B, mayB)
    d1 = B - S
    d2 = mayB - S
    return last(Tuple(d2)) > last(Tuple(d1)) || first(Tuple(d2)) > first(Tuple(d1))
end=#

md(i, j) = sum(map(abs, Tuple(i - j)))# + map(abs, Tuple(i - j))

function flood_fill(i, D, v, orig_i, beacons)
    if i ∉ beacons
        for d in cardinal_directions(2)
            j = i + d
            # u = j - orig_i
            u = md(orig_i, j)
            if !haskey(D, j) && u <= v#!is_further_away(u, v)#u <= v
                D[j] = no_beacon
                flood_fill(j, D, v, orig_i, beacons)
            end
        end
    end
end

#=function flood_fill(i, D, beacons, v)
    Q = Queue()
    enqueue!(Q, i)
    while !isempty(Q)
        j = dequeue!(Q)
        if j ∉ beacons &&
            enqueue!(Q)
        end
    end
end=#

get_x_bounds(beacons::Set{CartesianIndex{2}}) = extrema(last(Tuple(i)) for i in beacons)


function main(data)
    R = 2_000_000
    # R = 10
    D = initialise_map(data)

    sensors = Set{CartesianIndex{2}}(s for (s, _b) in data)
    beacons = Set{CartesianIndex{2}}(b for (_s, b) in data)

    directions = cartesian_directions(2)
    Q = Queue{CartesianIndex{2}}()

    # flood_fill(
    D2 = Dict{CartesianIndex{2}, Tuple{CartesianIndex{2}, Set{CartesianIndex{2}}}}()
    D3 = Dict{CartesianIndex{2}, Int}()

    # println(sensors)

    for (sᵢ, bᵢ) in data
        v = md(bᵢ, sᵢ)
        # radius = get_md_radius(sᵢ, v)
        # D2[sᵢ] = (bᵢ, radius)
        D3[sᵢ] = v
    end

    x_min, x_max = get_x_bounds(beacons)

    # 4122284 IS TOO LOW

    #=D4 = Dict{NTuple{2, CartesianIndex{2}}, Int}()
    for xᵢ in x_min:x_max
        i = CartesianIndex(R, xᵢ)
        for sᵢ in sensors
            u = md(i, sᵢ)
            D4[(sᵢ, i)] = u
        end
    end=#
    # println(D4)

    m = maximum(d for (_sᵢ, d) in D3) + 1
    S = Set{CartesianIndex{2}}()
    res = 0
    for xᵢ in (x_min - m):(x_max + m)
        i = CartesianIndex(R, xᵢ)
        for sᵢ in sensors
            v = D3[sᵢ]
            # u = D4[(sᵢ, i)]
            u = md(i, sᵢ)
            if u <= v && i ∉ S && i ∉ sensors && i ∉ beacons
                # println(i)
                push!(S, i)
                res += 1
            end
        end
    end

    #=for xᵢ in (x_min - m):(x_max + m)
        i = CartesianIndex(R, xᵢ)
        if i ∈ beacons
            print("B")
        elseif i ∈ sensors
            print("S")
        elseif i ∈ S
            print("#")
        else
            print(".")
        end
    end=#
    println()
    #=for sᵢ in sensors
        res += sum(D4[(sᵢ, CartesianIndex(R, xᵢ))] <= D3[sᵢ] for xᵢ in x_min:x_max)
    end=#
    # println(sensors)
    return res

    #=for (sᵢ, bᵢ) in data
        # v = bᵢ - sᵢ
        # v = md(bᵢ, sᵢ)
        # flood_fill(sᵢ, D, v, sᵢ, beacons)
        # v = bᵢ - sᵢ
        v = md(bᵢ, sᵢ)
        enqueue!(Q, sᵢ)
        # enqueue!(Q, bᵢ)
        while !isempty(Q)
            i = dequeue!(Q)
            if md(i, sᵢ) > v
                continue
            end
            for d in directions
                j = i + d
                # u = j - sᵢ
                u = md(j, sᵢ)
                # println("For $i, adjacent $j, MD $u from sensor (compared to $v), u < v = $(u < v) ")
                if j == bᵢ
                    continue
                    # println("Found beacon")
                    # break
                end
                if u <= v && j ∉ Q && j ∉ keys(D)
                    enqueue!(Q, j)
                end
            end
            # return
            if !haskey(D, i)
                D[i] = no_beacon
            end
        end
    end=#

    # return D
    #=res = 0
    for (i, s) in D
        if first(Tuple(i)) == R && s == no_beacon
            res += 1
        end
    end
    return res=#
end

println(main(data))

get_y_bounds(beacons::Set{CartesianIndex{2}}) = extrema(first(Tuple(i)) for i in beacons)

tf(i::CartesianIndex{2}) = sum(Tuple(i) .* (1, 4_000_000))

function allowed(i::CartesianIndex{N}) where {N}
    MIN_COORD, MAX_COORD = 0, 4_000_000
    # MIN_COORD, MAX_COORD = 0, 20
    j = Tuple(i)
    return all(k >= MIN_COORD for k in j) && all(k <= MAX_COORD for k in j)
end

# does not include bounds!
function diag_line(a::CartesianIndex{2}, b::CartesianIndex{2})
    d = direction(b - a)
    # return ()

    # line = CartesianIndex{2}[]
    # i = a + d
    line = CartesianIndex{2}[a]
    i = a
    while i != b
        i += d
        push!(line, i)
        # i += d
    end
    return line
end

function get_md_radius(i::CartesianIndex{2}, r::Int)
    S = Set{CartesianIndex{2}}()
    bounds = Tuple(i + r * d for d in cardinal_directions(2))
    # offsets = (i + CartesianIndex(r, 0), i + CartesianIndex(r, 0), )
    for k in 2:4
        # R = bounds[k - 1]:bounds[k]
        # for j in R
            # push!(S, j)
        # end
        # push!(S, R)
        R = diag_line(bounds[k - 1], bounds[k])
        # append!(S, diag_line(bounds[k - 1], bounds[k]))
        for p in R
            push!(S, p)
        end
    end

    return S
end

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

function main2(data)
    MIN_COORD, MAX_COORD = 0, 4_000_000
    # MIN_COORD, MAX_COORD = 0, 20

    sensors = Set{CartesianIndex{2}}(s for (s, _b) in data)
    beacons = Set{CartesianIndex{2}}(b for (_s, b) in data)

    D = Dict{CartesianIndex{2}, Int}()

    for (sᵢ, bᵢ) in data
        v = md(bᵢ, sᵢ)
        D[sᵢ] = v
    end

    x_min, x_max = get_x_bounds(beacons)
    y_min, y_max = get_y_bounds(beacons)
    m = maximum(d for (_sᵢ, d) in D) + 1

    S = Set{CartesianIndex{2}}()

    #=for xᵢ in (x_min - m):(x_max + m), yᵢ in (y_min - m):(y_max + m)
        i = CartesianIndex(yᵢ, xᵢ)
        for sᵢ in sensors
            v = D[sᵢ]
            u = md(i, sᵢ)
            if u <= v && i ∉ S && i ∉ sensors && i ∉ beacons
                push!(S, i)
            end
        end
    end=#

    # println(length(S))

    #=for i in CartesianIndex(MIN_COORD, MIN_COORD):CartesianIndex(MAX_COORD, MAX_COORD)
        i ∈ S && continue
        i ∈ sensors && continue
        i ∈ beacons && continue
        allowed(i) || continue
        return tf(i)
    end=#

    for (n, (sᵢ, bᵢ)) in enumerate(data)
        v = md(sᵢ, bᵢ)
        R = get_md_radius(sᵢ, v)
        for k in 0:0
            R′ = get_outer_radius(R)
            R = R ∪ R′
        end
        println("Processing radius $(length(R)) of sensor $sᵢ ($(n)/$(length(data)))")
        for p in R
            d = direction(p - sᵢ)
            i = p + d
            i ∈ sensors && continue
            i ∈ beacons && continue
            allowed(i) || continue
            all(md(i, sⱼ) > sᵥ for (sⱼ, sᵥ) in D) || continue
            return i, tf(i)
        end
    end

    # return length(S)
end

println(main2(data))
