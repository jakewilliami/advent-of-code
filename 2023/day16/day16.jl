# Part 1 so many bugs :(
# Part 2 no good stop condition, 10 vs 100

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function dis(M)
    println(join((join(r) for r in eachrow(M)), '\n'))
end

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    return M
    # S = read(input_file, String)
    # L = readlines(input_file)
    # L = get_integers.(L)
    # return L
end

ismirror(c) = c in ('/', '\\')
issplitter(c) = c in ('|', '-')
isemptyspace(c) = c == '.'

function mirror_dir(c, d)
    if c == '/'
        # right
        if d == INDEX_RIGHT
            return INDEX_ABOVE
        # down
        elseif d == INDEX_BELOW
            return INDEX_LEFT
        # left
        elseif d == INDEX_LEFT
            return INDEX_BELOW
        # up
        elseif d == INDEX_ABOVE
            return INDEX_RIGHT
        end
    elseif c == '\\'
        # right
        if d == INDEX_RIGHT
            return INDEX_BELOW
        # down
        elseif d == INDEX_BELOW
            return INDEX_RIGHT
        # left
        elseif d == INDEX_LEFT
            return INDEX_ABOVE
        # up
        elseif d == INDEX_ABOVE
            return INDEX_LEFT
        end
    else
        error("unhandled mirror $c")
    end
end

function f!(M, beams)
    energised = Set((first(only(beams)),))
    n_unchanged = 0
    while true
        # TODO: queue rather than mutate beams
        start_length_energised = length(energised)
        start_beams = copy(beams)
        modifiers = []
        for (beam_i, (i, d)) in enumerate(beams)
            c = tryindex(M, i)
            if c === nothing
                # deleteat!(beams, beam_i)
                push!(modifiers, (:deleteat!, (beam_i,)))
                continue
            end
            push!(energised, i)
            if isemptyspace(c)
                beams[beam_i] = (i + d, d)
            elseif ismirror(c)
                d = mirror_dir(c, d)
                beams[beam_i] = (i + d, d)
            elseif issplitter(c)
                # d_op = opposite_direction(d)
                # if (c == '|' && (d in (INDEX_ABOVE, INDEX_BELOW) || d_op in (INDEX_ABOVE, INDEX_BELOW))) || (c == '-' && (d in (INDEX_LEFT, INDEX_RIGHT) || d_op in (INDEX_LEFT, INDEX_RIGHT)))
                if (c == '|' && d in (INDEX_ABOVE, INDEX_BELOW)) || (c == '-' && d in (INDEX_LEFT, INDEX_RIGHT))
                    beams[beam_i] = (i + d, d)
                else
                    if c == '|'
                        beams[beam_i] = (i + INDEX_ABOVE, INDEX_ABOVE)
                        push!(modifiers, (:push!, (i + INDEX_BELOW, INDEX_BELOW)))
                    elseif c == '-'
                        beams[beam_i] = (i + INDEX_LEFT, INDEX_LEFT)
                        push!(modifiers, (:push!, (i + INDEX_RIGHT, INDEX_RIGHT)))
                    else
                        error("unhandled splitter $c")
                    end
                end
            else
                error("unhandled char $c")
            end
        end
        indices_to_delete = (only(a) for (m, a) in modifiers if m == :deleteat!)
        deleteat!(beams, indices_to_delete)
        for (m, a) in modifiers
            if m == :push!
                push!(beams, a)
            end
        end
        # println(energised, "    ", beams)
        # println('='^20)
        # println(energised)
        # println(length(energised))
        # println(beams)
        # println('='^20)

        if length(energised) == start_length_energised
            n_unchanged += 1
        end
        if n_unchanged > 100
            break
        end
        # println(beams)
        # length(energised) == start_length_energised && break
        # length(energised) == 46 && break
        # isempty(beams) && break
        # beams == start_beams && break
        # beams == start_beams && length(energised) == start_length_energised && break
    end

    #=
    M2 = fill('.', size(M))
    for i in energised
        M2[i] = '#'
    end
    dis(M2)
    =#

    return energised
end

function part1(data)
    beams = [(CartesianIndex{2}(), INDEX_RIGHT)]
    energised = f!(data, beams)
    return length(energised)
end

function part2(data)
    start_indices = []
    for ri in axes(data, 1)
        push!(start_indices, (CartesianIndex(ri, 1), INDEX_RIGHT))
        push!(start_indices, (CartesianIndex(ri, size(data, 1)), INDEX_LEFT))
    end
    for ci in axes(data, 2)
        push!(start_indices, (CartesianIndex(1, ci), INDEX_BELOW))
        push!(start_indices, (CartesianIndex(size(data, 2), ci), INDEX_ABOVE))
    end


    energised = []
    for si in start_indices
        println(si)
        beams = [si]
        push!(energised, length(f!(data, beams)))
    end

    return maximum(energised)
end

function main()
    data = parse_input("data16.txt")
    # data = parse_input("data16.test.txt")
    # dis(data)

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 6795
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
    # not 7143 too low
end

main()
