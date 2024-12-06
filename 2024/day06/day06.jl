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
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function ff(data)
    for i in CartesianIndices(data)
        if data[i] == '^'
            return i
        end
    end
end

function part1(data)
    d = INDEX_UP
    i = ff(data)
    seen = Set((i,))
    while true
        j = i + d
        c = tryindex(data, j)
        if isnothing(c)
            return length(seen)
        end
        if c == '#'
            d = rotr90(d)
        end
        i += d
        push!(seen, i)
    end
end

function sim(start_i, oi, data)
    i = start_i
    d = INDEX_UP
    start_d = d
    # second_pos = d + i
    # seen = Set(((i,d),))
    seen = Set()
    corners = Set()
    while true
        if oi == CartesianIndex(9, 2)
            # @info i, d
        end
        j = i + d
        d1=d
        c = tryindex(data, j)
        if isnothing(c)
            return (false, corners)
        end
        if c == '#'
            push!(corners, i)
            d = rotr90(d)
        end
        # i += d
        #=
        if i  === start_i && length(corners) >= 3
            # c′ = tryindex(data, j)
            # if !isnothing(c′) && c′ == '#'
            if d == start_d
                return (true, corners)
            # else
                # return (false, corners)
            end
        # else
            # return false, corners
        end=#

        # if i == start_i
            # return (true, corners)
        # end
        # i += d

        # push!(seen, (i, d))
        # @info i, d

        if (i, d1) ∈ seen
            return (true, corners)
        end
        push!(seen, (i, d))
        i += d

    end
end

function part21(data)
    j = ff(data)
    r = 0
    corner_pos = Set()
    for i in CartesianIndices(data)
        i == j && continue
        loop, corners = sim(i, data)
        if loop && !all(==(corners), corner_pos)
            r += 1
        end
        push!(corner_pos, corners)
    end
    r
end

function sim2(i, data)

end

function possible_obstructions(data)
    S = Set()
    for i in CartesianIndices(data)
        if data[i] != '#' && data[i] != '^'
            push!(S, i)
        end
    end
    S
end

function sim(start_i, oi, data)
    i = start_i
    d = INDEX_UP
    seen = Set()
    seen1 = Set()
    corners = Set()
    while true
        # if oi == CartesianIndex(3, 3)
            # @info i, d
        # end
        if (i, d) ∈ seen  # || i ∈ seen1
            return (true, corners)
        end
        push!(seen, (i, d))
        # push!(seen1, i)

        j = i + d
        c = tryindex(data, j)
        if isnothing(c)
            return (false, corners)
        end
        if c == '#'
            push!(corners, i)
            d = rotr90(d)
            if (i, d) ∈ seen  #|| (i + d, d) ∈ seen
                return (true, corners)
            end
        end

        # I HAD AN EDGE CASE WHERE I WALKED OVER OBSTACLES
        # push!(seen, (i, d))
        if data[i + d] != '#'
            i += d
        end
    end
end

function part2(data)
    # data[CartesianIndex(9, 2)] = '#'
    # sim(ff(data), CartesianIndex(9,2), data)
    # return 0
    j = ff(data)
    r = 0
    corner_pos = Set()
    obs = Set()
    P = possible_obstructions(data)
    for (n, i) in enumerate(P)
        # println("$n/$(length(P))")
        # @info i
        data′ = deepcopy(data)
        @assert data[i] == data′[i] == '.'
        data′[i] = '#'
        loop, corners = sim(j, i, data′)
        if i == CartesianIndex(3, 3)
            println(loop)
        end
        if loop #&& !any(==(corners), corner_pos)
            push!(obs, i)
            r += 1
        end
        push!(corner_pos, corners)
    end
    # println(obs)
    length(obs)
    r
end

function main()
    data = parse_input("data06.txt")
    # data = parse_input("data06.test.txt")
    # data = parse_input("data06.test2.txt")

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

# NOT 1455, too low
# NOT 1467, too low
# NOT 1475, too low
