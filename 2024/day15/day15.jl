using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

const Index = CartesianIndex{2}

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = strip(read(input_file, String))
    # L = strip.(readlines(input_file))
    S1, S2 = split(S, "\n\n")
    M = Parsing._lines_into_matrix(split(strip(S1), '\n'))
    S2 = strip.(split(S2, '\n'))
    return M, join(S2)
    # L = get_integers.(L)
    return L
end

function dir(c::Char)
    if c == '>'
        return INDEX_RIGHT
    elseif c == '<'
        return INDEX_LEFT
    elseif c == 'v'
        return INDEX_DOWN
    elseif c == '^'
        return INDEX_UP
    else
        error("unhandled '$c'")
    end
end

isrobot(c) = c == '@'
isbox(c) = c == 'O'
iswall(c) = c == '#'
isfree(c) = c == '.'

function robot_pos(M)
    for i in CartesianIndices(M)
        if isrobot(M[i])
            return i
        end
    end
end

function next_wall(M, i, d)
    hasindex(M, i) && iswall(M[i]) && return i
    j = i + d
    while hasindex(M, j) && !iswall(M[j])
        j += d
    end
    return j
end

function can_move(M, i, d)
    hasindex(M, i) && iswall(M[i]) && return false
    j = i + d
    # println("here: j=$j, $(M[j])")
    if hasindex(M, j) && isfree(M[j])
        return true
    end
    j += d
    hasindex(M, j) || return false
    while true
        # while hasindex(M, j) && (isfree(M[j]) || isbox(M[j])) && !iswall(M[j])
        # println("here: j=$j, $(M[j]), $(isfree(M[j]))")
        if !isbox(M[j])#iswall(M[j]) || isfree(M[j])
            break
        end
        j += d
    end
    # println("here: j=$j, $(M[j-d]), $(isfree(M[j-d]))")
    return isfree(M[j])
end

function next_move_stop(M, i, d)
    hasindex(M, i) && iswall(M[i]) && return i
    j = i + d
    while hasindex(M, j) && (isfree(M[j]) || isbox(M[j])) && !iswall(M[j])
        j += d
    end
    if !isfree(M[j - d])
        return i
    end
    return j - d
end

# returns new robot position
function move!(M, i, inst::Char)
    i = robot_pos(M)
    initial_i = i
    d = dir(inst)
    c = M[i]
    @assert isrobot(c)

    can_move(M, i, d) || return i

    j = i + d

    # SOMEHOW AN EDGE CASE THAT WAS NOT PICKED UP BY CAN MOVE, BUT ONLY ENCOUNTERED AFTER 380 STEPS IN THE TEST CASE
    if iswall(M[j])
        return i
    end
    # if isfree(M[j])
        # M[i] = '.'
        # M[j] = '@'
    # end

    # println("here")

    k = j
    while isbox(M[k])
        k += d
    end

    while true
        # println(k)
        c = M[k - d]
        # M[k] = iswall(c) ? '.' : c
        # Account for edge case where robot is moving but surrounded by boxes
        c = '.'
        if isrobot(M[k - d])
            c = '@'
        elseif isbox(M[k - d])
            # then either we are pushing a row of boxes or the robot has a box behind it
            if !isrobot(M[k])
                # c = '.'
            # else
                c = 'O'
            end
        end
        M[k] = c
        k == i && break
        k -= d
    end
    return k + d

    # k -= d
    k′ = k - d
    println(i,k, k′)
    while k′ != i
        println("M[k′]=M[$k′]='$(M[k′])', M[k]=M[$k]='$(M[k])'")
        M[k] = M[k′]
        k = k′
        k′ -= d
    end
    # if k != i
        # M[k] = '.'
    # end
    # return i + d
    return k′






    wi = next_wall(M, i, d)

    # if isfree(M[i])
        # M[i] = '.'
        # M[j] = '@'
        # return j
    # end

    old_c = c
    next_i = next_move_stop(M, i, d)
    println(next_i)
    # println(i, d, next_i)
    # println(next_i)
    while j != next_i
    # while can_move(M, j, d)
        println("j=$j")
        M[i] = old_c
        new_c = M[j]
        M[j] = c
        old_c = c
        c = new_c
        i = j
        j += d
    end
    M[j] = c
    M[initial_i] = '.'
    return initial_i + d

    while j != wi
        M[i] = '.'
        new_c = M[j]
        M[j] = c
        c = new_c
        isfree(c) && return j
        i = j
        j += d
    end
    return j - d

    hasindex(M, j) || return i
    iswall(M[j]) && return i

    if isfree(M[j])
        M[i] = '.'
        M[j] = '@'
        return j
    end

    n = 0
    while hasindex(M, j) && isbox(M[j])
        # move from i to j
        M[i] = '.'
        new_c = M[j]
        M[j] = c
        c = new_c
        i = j
        j += d
        n += 1
    end
    M[j] = c
    M[j - n*d] = '@'
    return j - d
end

function displ(M)
    io = IOBuffer()
    for row in eachrow(M)
        for c in row
            print(io, c)
        end
        println(io)
    end
    s = String(take!(io))
    println(s)
    return s
end

function gps(i::Index)
    y, x = Tuple(i)
    100*(y - 1) + (x - 1)
end

function answer(M)
    sum(CartesianIndices(M)) do i
        isbox(M[i]) || return 0
        gps(i)
    end
end

function part1(M, I)
    # println(repr(I))
    M = deepcopy(M)
    i = robot_pos(M)
    # displ(M)
    for (n, c) in enumerate(I)
        ri = i
        # println(c, ' ', n)
        i = move!(M, i, c)
        # o1 = displ(M)
        # println("$ri -> $i")

        # go(M, ri, dir(c))
        # o2 = displ2(i)
        # if strip(o1) != strip(o2)
            # error("s1, s2 = $(repr(o1)), $(repr(o2))")
        # end
    end
    answer(M)
end

function double(c::Char)
    if c == '.'
        return ".."
    elseif c == 'O'
        return "[]"
    elseif c == '#'
        return "##"
    elseif c == '@'
        return "@."
    else
        error("unhandled: '$c'")
    end
end

function new_map(M)
    # M′ = fill('.', size(M) .* 2)
    # for i in CartesianIndices(M)
    # end
    # V = join.(eachrow(M))
    # return Parsing._lines_into_matrix(V, double)

    V = String[]
    io = IOBuffer()
    for row in eachrow(M)
        for c in row
            print(io, double(c))
        end
        push!(V, String(take!(io)))
    end
    return Parsing._lines_into_matrix(V)
end

function answer2(M)
    # println(repr(M))
    sum(CartesianIndices(M)) do i
        # println(i)
        # println(M[i])
        M[i] == '[' || return 0
        gps(i)
    end
end

function indices_to_move(M, si, d)
    Q = Queue{Index}()
    S = Set{Index}()
    push!(Q, si)
    while !isempty(Q)
        i = dequeue!(Q)
        j = i + d
        if M[j] ∈ "[]"
            enqueue!(M, j)

            # check if there's another box to be pushed
            if M[j] == '['
                error("todo")
            elseif M[j] == ']'
            else
                error("unreachable")
            end
        end
    end
end

struct Box
    left::Index
    right::Index
end

function boxes_to_move(M, b::Box, d)
    Q = Queue{Index}()
    S = Seen{Index}()
    enqueue!(Q, b.left)
    enqueue!(Q, b.right)
    while !isempty(Q)
        # b =
        # TODO
    end
end

function moveboxes!(M, b::Box, d, walls, boxes)
    # TODO
end

# adapted from https://www.reddit.com/r/adventofcode/comments/1hele8m/comment/m24z445.
# help from https://www.reddit.com/r/adventofcode/comments/1hele8m/comment/m24swhr/
function move2!(M, i, d)
    j = i + d
    if M[j] == '#'
        return false
    elseif M[j] == '['
        if  !move2!(M, j + INDEX_RIGHT, d) || !move2!(M, j, d)
            return false
        end
    elseif M[j] == ']'
        if !move2!(M, j + INDEX_LEFT, d) || !move2!(M, j, d)
            return false
        end
    end
    M[j] = M[i]
    M[i] = '.'
    return true
end

function mkbox(M, i)
    c = M[i]
    @assert c ∈ "[]"
    if c == '['
        return Box(i, i + INDEX_RIGHT)
    elseif c == ']'
        return Box(i + INDEX_LEFT, i)
    else
        error("unreachable")
    end
end

function part2(M, I)
    M = deepcopy(M)
    M = new_map(M)
    displ(M)

    # Get locations
    walls = Set{Index}()
    boxes = Set{Box}()
    for i in CartesianIndices(M)
        c = M[i]
        if c == '#'
            push!(walls, i)
        elseif c ∈ "[]"
            push!(boxes, mkbox(M, i))
        end
    end

    i = robot_pos(M)
    for (n, c) in enumerate(I)
        println(c, ' ', n)
        d = dir(c)

        M′ = deepcopy(M)
        if move2!(M, i, d)
            i += d
        else
            M = M′
        end

        # displ(M)

        #=



        j = i + d
        if j ∈ walls
            continue
        end
        if M[j] == '.'
            i = j
            continue
        end
        @assert M[j] ∈ "[]"
        b = mkbox(M, j)
        i = moveboxes!(M, b, d, walls, boxes)
        =#
    end
    answer2(M)
end

function main()
    data = parse_input("data15.txt")
    # data = parse_input("data15.test.txt")
    # data = parse_input("data15.test2.txt")
    # data = parse_input("data15.test3.txt")

    # Part 1
    part1_solution = part1(data...)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data...)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()

# 1453900 is too low
