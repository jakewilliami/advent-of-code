# We are given another matrix of characters, this time representing a
# plane of space with mirrors and splitters.
#
# Part 1: a beam of light comes in from the top left of the grid, moving
# right.  We have to simulate it moving around, being bounced around by
# mirrors and split into multiple beams by splitters.  Each index it goes
# across will be energised.  What is the number of indices that are energised
# at the end of the simulation?
#
# Part 2: the beam of light can come from any direction on the edge of the
# grid.  Find the initial direction and position of the beam such that the
# number of indices energised at the end of the simulation is maximised.
#
# I took a long time to complete part 1, as I, for some reason, just had so
# many bugs.  Skill issue, I guess.  I took around 1.5 hours.  For I think
# one of the first times this year I actually had to get out the old pen and
# paper, and make sure I had everything splitting and bouncing around correctly
# (I hadn't).  Anyway, I finally got that working, but I had guests over so I
# couldn't work on part 2 for a little while.  Once I got to part 2, it was
# quite slow to run because I didn't implement memoisation/dynamic progragramming.
# As a result, I didn't have a good stop condition and I had a small bug in
# part 2 which was a problem.  Pretty happy with the final queue system I have
# written with memoisation implemented.

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using DataStructures

parse_input(input_file::String) = readlines_into_char_matrix(input_file)


### Part 1 ###

mutable struct Beam
    pos::CartesianIndex{2}
    dir::CartesianIndex{2}

    function Beam(pos::CartesianIndex{2}, dir::CartesianIndex{2})
        is_direction(dir) || error("A direction must have no magnitude")
        return new(pos, dir)
    end
end

Base.hash(beam::Beam) = hash((beam.pos, beam.dir))

# Move the beam to the next position in the current direction
function move!(beam::Beam)
    beam.pos += beam.dir
    return beam
end

# Move the beam to the next position in a new direction
function move!(beam::Beam, dir::CartesianIndex{2})
    is_direction(dir) || error("A direction must have no magnitude")
    beam.dir = dir
    return move!(beam)
end

function mirror_dir(M::Matrix{Char}, beam::Beam)
    c = M[beam.pos]
    i = origin(2)
    rd = CartesianIndex(reverse(beam.dir.I))

    if c == '/'
        return i - rd
    elseif c == '\\'
        return i + rd
    else
        error("unhandled mirror $c")
    end
end

function simulate_beam_energising(M::Matrix{Char}, start_beam::Beam)
    Q, energised, seen = Queue{Beam}(), Set{CartesianIndex{2}}(), Set{UInt}()
    enqueue!(Q, start_beam)

    while !isempty(Q)
        beam = dequeue!(Q)

        while hasindex(M, beam.pos)
            h = hash(beam)
            h ∈ seen && break
            push!(seen, h)
            # println(beam)

            push!(energised, beam.pos)
            c = M[beam.pos]

            if c == '.'
                move!(beam)
            elseif c ∈ "/\\"
                move!(beam, mirror_dir(M, beam))
            elseif c ∈ "|-"
                if (c == '|' && beam.dir in (INDEX_ABOVE, INDEX_BELOW)) ||
                    (c == '-' && beam.dir in (INDEX_LEFT, INDEX_RIGHT))
                    move!(beam)
                else
                    if c == '|'
                        enqueue!(Q, Beam(beam.pos + INDEX_BELOW, INDEX_BELOW))
                        move!(beam, INDEX_ABOVE)
                    elseif c == '-'
                        enqueue!(Q, Beam(beam.pos + INDEX_RIGHT, INDEX_RIGHT))
                        move!(beam, INDEX_LEFT)
                    else
                        error("unhandled splitter $c")
                    end
                end
            else
                error("unhandled char $c")
            end
        end
    end

    return energised
end

function part1(data::Matrix{Char})
    energised = simulate_beam_energising(data, Beam(CartesianIndex{2}(), INDEX_RIGHT))
    return length(energised)
end


### Part 2 ###

function collect_edge_indices(M::Matrix{Char})
    nrows, ncols = size(M)
    edges = Beam[]

    for ri in axes(M, 1)
        push!(edges, Beam(CartesianIndex(ri, 1), INDEX_RIGHT))
        push!(edges, Beam(CartesianIndex(ri, nrows), INDEX_LEFT))
    end

    for ci in axes(M, 2)
        push!(edges, Beam(CartesianIndex(1, ci), INDEX_BELOW))
        push!(edges, Beam(CartesianIndex(ncols, ci), INDEX_ABOVE))
    end

    return edges
end

function part2(data::Matrix{Char})
    edges = collect_edge_indices(data)
    return maximum(length(simulate_beam_energising(data, beam)) for beam in edges)
end

function main()
    data = parse_input("data16.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 6795
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 7154
    println("Part 2: $part2_solution")
    # not 7143 too low
end

main()
