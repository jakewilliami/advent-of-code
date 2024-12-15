# There a two parts to the input: a grid, and some instructions.  In the grid,
# there is a robot (represented by the @ character), some boxes (represented by
# O), some walls (represented by #), and free space (represented by .).  The
# robot can move in each four cardinal directions as per its instructions, and
# it can move any number of boxes, but it cannot move boxes or itself into any
# walls.
#
# Tricky problem today.  In theory/on paper it's simple, but in practice, any
# implementation is rather hard to get right.  Part one asked us to just simulate
# its movements as per the instructions and calculate the position of each box
# at the end of the simulation.  I did this very slowly because I had so many
# implementation issues.  I even had a bug that was very rare to occur; in the
# larger test example, this was only encountered after 380 steps.
#
# In part two, everything was wider, which mean that boxes take up two squares
# and can potentially move two boxes.  I was reading through the solutions thread
# for some help and it was clear that a recursive solution was best for this:
#   <https://www.reddit.com/r/adventofcode/comments/1hele8m/comment/m24swhr/>
#
# I ended up writing a solution to part two based on this other solution:
#   <https://www.reddit.com/r/adventofcode/comments/1hele8m/comment/m24z445/>
#
# I understand how it works, but I think it would have taken me a long time to
# get right without the guidance...

using AdventOfCode.Parsing, AdventOfCode.Multidimensional


### Parse Input ###

const Index = CartesianIndex{2}
const DIRECTIONS = Dict{Char, Direction}(
    '>' => INDEX_RIGHT,
    '<' => INDEX_LEFT,
    'v' => INDEX_DOWN,
    '^' => INDEX_UP,
)

function dir(c::Char)
    haskey(DIRECTIONS, c) || error("Unhandled direction character '$c'")
    return DIRECTIONS[c]
end

function parse_input(input_file::String)
    S = strip(read(input_file, String))
    S1, S2 = split(S, "\n\n")
    M = Parsing._lines_into_matrix(split(strip(S1), '\n'))
    I = join(strip.(split(S2, '\n')))
    L = Direction[dir(c) for c in I]
    return M, L
end


### Part 1 ###

isrobot(c::Char) = c == '@'
isbox(c::Char) = c ∈ "O[]"
iswall(c::Char) = c == '#'
isfree(c::Char) = c == '.'

function find_robot(M::Matrix{Char})
    for i in CartesianIndices(M)
        if isrobot(M[i])
            return i
        end
    end
end

# Returns new robot position
function move!(M::Matrix{Char}, i::Index, d::Direction)
    c = M[i]
    j = i + d
    @assert isrobot(c) "M[i]=M[$i]=$(M[i])≠'@'"

    # Case 1: next position is free space
    if isfree(M[j])
        M[j] = M[i]
        M[i] = '.'
        return j
    end

    # Case 2: next position is a wall so we can't move
    if iswall(M[j])
        return i
    end

    # Case 3: next position is a box that we might be able to move
    @assert isbox(M[j])
    k = j
    while isbox(M[k])
        k += d
    end
    @assert !isbox(M[k])

    # We have reached the end of a row of boxes.  Can we move them?
    # Case 3.1: No, there's a wall in the way
    if iswall(M[k])
        return i
    end

    # Case 3.2: Yes, there's free space.  We can use a trick where we simply
    # move the first box to the end:
    # <https://www.reddit.com/r/adventofcode/comments/1hele8m/comment/m24swhr/>
    @assert isfree(M[k])
    M[k] = M[j]
    M[j] = M[i]
    M[i] = '.'
    return j
end

function gps(i::Index)
    y, x = Tuple(i)
    100*(y - 1) + (x - 1)
end

function part1(M, I)
    # Simulate robot movements as per instructions
    i = find_robot(M)
    for d in I
        i = move!(M, i, d)
    end

    # Sum together gps coordinates of each box after simulation
    return sum(CartesianIndices(M)) do i
        isbox(M[i]) || return 0
        gps(i)
    end
end


### Part 2 ###

function double(c::Char)
    if c == 'O'
        return "[]"
    elseif c == '@'
        return "@."
    else
        return repeat(c, 2)
    end
end

function double(M::Matrix{Char})
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

# Recursively move in direction d; adapted from:
# <https://www.reddit.com/r/adventofcode/comments/1hele8m/comment/m24z445/>
#
# Returns a boolean of whether or not it can move
#
# Because this function modifies the input matrix, it's a good idea to copy
# the matrix first before checking, in case you can't move and have to
# roll back the change.
function simulate!(M::Matrix{Char}, i::Index, d::Direction)
    j = i + d
    if M[j] == '#'
        return false
    elseif M[j] == '['
        if  !simulate!(M, j + INDEX_RIGHT, d) || !simulate!(M, j, d)
            return false
        end
    elseif M[j] == ']'
        if !simulate!(M, j + INDEX_LEFT, d) || !simulate!(M, j, d)
            return false
        end
    end
    M[j] = M[i]
    M[i] = '.'
    return true
end

# Apply simulation if the move is allowed
function move2!(M::Matrix{Char}, i::Index, d::Direction)
    M′ = deepcopy(M)
    if simulate!(M′, i, d)
        copyto!(M, M′)
        return i + d
    else
        return i
    end
end

function part2(M, I)
    # Simulate robot movements as per instructions
    M = double(M)
    i = find_robot(M)
    for d in I
        i = move2!(M, i, d)
    end

    # Sum together gps coordinates of each box after simulation
    return sum(CartesianIndices(M)) do i
        M[i] == '[' || return 0
        gps(i)
    end
end

function main()
    M, I = parse_input("data15.txt")

    # Part 1
    part1_solution = part1(deepcopy(M), I)
    @assert part1_solution == 1463715
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(deepcopy(M), I)
    @assert part2_solution == 1481392 part2_solution
    println("Part 2: $part2_solution")
end

main()
