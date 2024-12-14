using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

const I = CartesianIndex{2}

struct R
    pos::I
    velocity::I  # per second
end

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = get_integers.(L, negatives=true)
    # L = [l .- 1 for l in L]
    # I INCREMENTED WRONG BECAUSE ACCOUNT FOR NEGATIVE AND ALSO ZERO SPECIAL CASE
    # 0 indexing sucks
    function inc(x)
        iszero(x) && return 1
        # return x + 1
        x′ = abs(x)
        s = sign(x)
        (x′ + 1) * s
    end
    L = [(inc(a), inc(b), c, d) for (a, b, c, d) in L]
    L = [R(I(b, a), I(d, c)) for (a, b, c, d) in L]
    return L
end

function Base.mod1(i::CartesianIndex{2}, j::CartesianIndex{2})
    y1, x1 = Tuple(i)
    y2, x2 = Tuple(j)
    return CartesianIndex{2}(mod1(y1, y2), mod1(x1, x2))
end

function positions(robots)
    D = DefaultDict(0)
    for robot in robots
        D[robot.pos] += 1
    end
    D
end

function next_pos(robot, sz, n)
    mod1(robot.pos + (robot.velocity * n), sz)
end

next_pos(robot, sz) = next_pos(robot, sz, 1)

function move(robots,sz,n)
    D = DefaultDict(0)
    for robot in robots
        # i = mod1(robot.pos + (robot.velocity * n), sz)
        # if i == CartesianIndex(3,2)
            # println(robot.pos, " => ", i, " = + ", robot.velocity, " * ", n, " = ", robot.velocity * n, " mod1 ", sz)
        # end
        D[next_pos(robot, sz, n)] += 1
    end
    return D
end

function safety_factor(D,sz)
    Q = fill(0, 2,2)
    ym, xm = Tuple(sz)
    yd, xd = ym ÷ 2, xm ÷ 2
    # println("sz=$sz, ym=$ym, xm=$xm, yd=$yd, xd=$xd")
    for (k, v) in D
        y, x = Tuple(k)
        # I DIDN'T READ THIS BIT
        if y == (yd + 1) || x == (xd + 1)
            continue
        end
        top = (yd < y ≤ ym) + 1
        left = (xd < x ≤ xm) + 1
        Q[top, left] += v
    end
    # println(Q)
    return prod(Q)
end

function displ(D, sz)
    io = IOBuffer()
    y, x = Tuple(sz)
    for row in 1:y
        for col in 1:x
            i = I(row, col)
            if haskey(D, i)
                print(io, D[i])
            else
                print(io, '.')
            end
        end
        println(io)
    end
    String(take!(io))
end

function part1(data,sz)
    # p=2,4 v=2,-3
    # data = [R(I(4+1,2+1), I(2+1,-3-1))]
    # println(displ(positions(data),sz))
    D = move(data, sz,100)
    # println(safety_factor(D,sz))
    # println(displ(D, sz))

    # return
    # println(D)
    # println(displ(D,sz))

    safety_factor(D,sz)
end

# Hah.  I thought the precise size would matter
# why was figuring out the shape of the tree so hard
# as with yesterday, unfortunately no sample output!
#
# Apparently I don't know what a christmas tree looks like:
# https://www.reddit.com/r/adventofcode/comments/1hdwy3z/
#
# We just have to look for the solution:
# https://www.reddit.com/r/adventofcode/comments/1hdw23y/comment/m1z8zpi/
# https://www.reddit.com/r/adventofcode/comments/1hdw5op/
#
# The solution:
# https://www.reddit.com/r/adventofcode/comments/1hdw23y/comment/m1z827k/
# https://www.reddit.com/r/adventofcode/comments/1hdw23y/comment/m1z8t3k/
function christmas_tree(sz)
    S = Set{I}()
    ym, xm = Tuple(sz)
    yd, xd = ym ÷ 2, xm ÷ 2
    println("sz=$sz, ym=$ym, xm=$xm, yd=$yd, xd=$xd")
    push!(S, I(1, xd + 1))
    # only go as far down as we can within the bounds of the box, so that is
    # half the number of columns
    # for row in 2:(ym - 1)
    for row in 2:(xd + 1)
        # println(I(row, xd + 1 - row + 1), I(row, xd + row))
        push!(S, I(row, xd + 1 - row + 1))
        push!(S, I(row, xd + row))
    end
    # for i in 1:xm
    #     push!(S, I(ym - 1, i))
    # end

    # trunk
    for i in (xd+2):ym
        push!(S, I(i, xd + 1))
    end

    # check they are all in bounds
    for s in S
        y, x = Tuple(s)
        @assert y ≤ ym && x ≤ xm s
    end

    S
end

function positions_of_robot(robot::R, sz)
    S = Set{I}()
    i = next_pos(robot, sz)
    while i ∉ S
        push!(S, i)
        i = next_pos(R(i, robot.velocity), sz)
    end
    S
end

# this mapping is actually a one-to-one bipartite graph i think
# # Construct a bipartite graph G=(U,V,E), where U is the set of robots, V is the set of positions, and E contains edges representing valid robot-position pairings.
# Use a bipartite matching algorithm (e.g., Hopcroft–Karp algorithm) to find the maximum matching in G.
# this is fun because i forgot everything about graph theory but i have a plan
using Graphs, BipartiteMatching
function find_christmas_tree_mapping(robots, sz)
    CS = sort(collect(christmas_tree(sz)))
    G = SimpleGraph(length(robots) + length(CS))
    nr = length(robots)

    G′ = falses(length(robots), length(CS))
    println(size(G′))

    for (i, robot) in enumerate(robots)
        found = false
        for j in positions_of_robot(robot, sz)
            if j ∈ CS
                found = true
                k = findfirst(==(j), CS)
                @assert !isnothing(k)
                add_edge!(G, i, nr + k)
                G′[i, k] = true
            end
        end
        if !found
            println("WARN: VALID POSITION NOT FOUND FOR ROBOT $i")
        end
    end

    @assert is_bipartite(G)

    # returns matching of rows => columns (i.e., robots => christmas tree positions)
    D, C = findmaxcardinalitybipartitematching(G′)
    D, C = findgreedybipartitematching(G′)
    println(C)
    println(length(D))
    println(D)
    D′ = Dict{Int, I}()
    for (ri, ctp) in D
        D′[ri] = CS[ctp]
    end
    return D′

    matching = bipartite_map(G)
    return matching, length(matching)

    mapping = Dict()
    for u in 1:nr
        v = matching[u]
        if v > 0 && v > nr
            mapping[u] = v - nr
        end
    end
    # plot(G)
    return mapping

    return matching
    D = Dict{I, Int}()
    for (i, robot) in enumerate(robots)
        P = positions_of_robot(robot, sz)
        println(P)
        P′ = Set{I}()
        for j in christmas_tree(sz)
            if j ∈ P
                push!(P′, j)
            end
        end
        @assert length(P′) == 1 "non-unique mapping ($P′)"
        j = only(P′)
        @assert !haskey(D, j) "position already taken"
        D[j] = i
    end
    D
end

function seconds_till_in_position(robot::R, target::I, sz)
    n = 0
    i = next_pos(robot, sz)
    # println(i)
    # println(target)
    while true
        if i == target
            return n
        end
        i = next_pos(R(i, robot.velocity), sz)
        n += 1
    end
end

function part2old(robots,sz)

    D = DefaultDict(0)
    for s in christmas_tree(sz)
        D[s] += 1
    end
    println(displ(D,sz))
    println(length(christmas_tree(sz)))
    # println(length(data))
    # TOO SLOW
    #=
    S = christmas_tree(sz)
    n = 1
    D = move(data, sz, 1)
    while Set(keys(D)) != S
        n += 1
    end
    n
    =#
    S = sort(collect(christmas_tree(sz)))

    # TODO: figure out all of the ways a robot can move
    # then find a mapping for christmas tree position to robot
    # then find how long that will take with gcd or whatever it is (monkeys)

    D = find_christmas_tree_mapping(robots, sz)
    for (i, robot) in enumerate(robots)
        # println("$i: (initial pos $(robot.pos)) target: $(D[i]), time: $(seconds_till_in_position(robot, D[i], sz)) because $(next_pos(robot, sz, seconds_till_in_position(robot, D[i], sz)))")
    end
    # println(D)

    println([seconds_till_in_position(robot, D[i], sz) for (i, robot) in enumerate(robots)])
    lcm((seconds_till_in_position(robot, D[i], sz) for (i, robot) in enumerate(robots))...)
end

function n_in_row(positions,sz,n)
    for i in I(1, 1):sz
        y, x = Tuple(i)
        if all(I(y, x + j) ∈ positions for j in 0:(n - 1))
            return true
        end
    end
    return false
end

robot_positions(robots) = [robot.pos for robot in robots]

function countmap(positions)
    D = DefaultDict(0)
    for p in positions
        D[p] += 1
    end
    D
end

function part2(robots,sz)
    n = 0
    while true
        positions = next_pos.(robots, sz, n)
        if n_in_row(positions,sz,10)
            println("FOUND: $n")
            println(displ(countmap(positions),sz))
        end
        n += 1
    end
end

function main()
    data, sz = parse_input("data14.txt"), I(103, 101)
    println("N ROBOTS: $(length(data))")
    # data, sz = parse_input("data14.test.txt"), I(7, 11)
    # data, sz = parse_input("data14.test2.txt"), I(7, 11)

    # Part 1
    part1_solution = part1(data,sz)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data,sz)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
