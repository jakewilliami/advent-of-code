# Interesting problem today.  We were given a list of robots, each with a starting
# position and a velocity.  They travel around, but if they go off the specified
# grid, they teleport to the other side.  We had to simulate them moving around
# the grid.  Both the number of rows and columns are odd, meaning that there is a
# middle row and column.  Robots that end up in the middle don't count towards and
# particular quadrant.  (I didn't read this initially and that took some time to
# realise.)
#
# In part one, we simulated them moving for 100 seconds.  The number we give as
# our answer is the product of the sum of robots in each quadrant of the grid at
# the end of the simulation.  I was slow to do this, because I had some annoying
# bugs.  In particular, I was treating the grid as 1-indexed but the problem was
# not, so I had to offset the starting positions.  In doing so, I didn't properly
# handle the offsetting of negative or zero values.  I also had that misunderst-
# anding of the calculation of the number of robots in each quadrant.
#
# Part two was particularly interesting.  We had to find out how many simulation
# iterations (seconds) were needed before the robots autonomously formed the
# shape of a Christmas tree.  I thought that means that the whole grid formed a
# Christmas tree.  Therefore, we can calculate the required indices for the
# Christmas tree, find out all of the positions that each robot can be in, and
# create a one-to-one bipartite mapping of robot -> Christmas tree position.
# Then, find the lowest common multiple (lcm) or greatest common divisor (gcd)
# of each of the number of cycles it takes for each robot to get to their
# respective Christmas tree position (a bit like we did with monkeys a couple
# of years ago).
#
# This was, however, not the case.  Apparently I don't know what a Christmas
# tree looks like:
#   <https://www.reddit.com/r/adventofcode/comments/1hdwy3z/>
#
# We just have to look for the solution somewhat manually:
#   <https://www.reddit.com/r/adventofcode/comments/1hdw23y/comment/m1z8zpi/>
#   <https://www.reddit.com/r/adventofcode/comments/1hdw5op/>
#
# So the solution hints that helped me here are:
#   <https://www.reddit.com/r/adventofcode/comments/1hdw23y/comment/m1z827k/>
#   <https://www.reddit.com/r/adventofcode/comments/1hdw23y/comment/m1z8t3k/>
#
# That is, the final Christmas tree is inside a bounding box, which means we
# can look for certain heuristics, such as many indices in a row, in order to
# find the tree pattern.
#
# Since the initial implementation for part 2:
#   <github.com/jakewilliami/advent-of-code/blob/e408a417/2024/day14/day14.jl#L128-L151>
#
# I took some time to improve the heuristic-checking algorithm:
#   <github.com/jakewilliami/advent-of-code/blob/a4bfb60b/2024/day14/day14.jl#L131-L165>
#
# But now I am using a system whereby I check the entropy of the arrangement of
# robots to confirm if I have found the Christmas tree eater egg or not.  We say
# we have found it if the entropy score is greater than 27.8%.  This now runs
# much faster than previous heuristic-checking algorithms.  Though, intuitively,
# I would expect more structured arrangements to have a *lower* entropy score? I
# guess that to make a Christmas tree, you need fewer robots occupying the same
# positions, so you have greater entropy as a result of it.

### Parse Input ###

const Index = CartesianIndex{2}

mutable struct Robot
    pos::Index
    velocity::Index  # per second
end

const GRID_SIZE = Index(103, 101)
const ROBOT_PAT = r"^p=(?<ix>-?\d+),(?<iy>-?\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)$"

function parse_robot(s::AbstractString)
    m = match(ROBOT_PAT, strip(s))
    @assert !isnothing(m)
    ix, iy, vx, vy = parse.(Int, (m[:ix], m[:iy], m[:vx], m[:vy]))

    return Robot(Index(iy, ix), Index(vy, vx))
end

parse_input(input_file::String) =
    Robot[parse_robot(s) for s in eachline(input_file)]


### Part 1 ###

function Base.mod(i::CartesianIndex{2}, j::CartesianIndex{2})
    y1, x1 = Tuple(i)
    y2, x2 = Tuple(j)
    return CartesianIndex{2}(mod(y1, y2), mod(x1, x2))
end

# Set a robot's position after n seconds
function next!(robot::Robot, n::Int)
    robot.pos = mod(robot.pos + (robot.velocity * n), GRID_SIZE)
    return robot
end
function next!(robots::Vector{Robot}, n::Int)
    for robot in robots
        next!(robot, n)
    end
    return robots
end
next!(robot::Union{Robot, Vector{Robot}}) = next!(robot, 1)

# Takes a vector of robots (which each have positions) and returns its "safety
# factor," which is just the product of the counts of elements in each four
# quadrants of the grid
function safety_factor(robots::Vector{Robot})
    # First, get a count map
    D = Dict{Index, Int}()
    for robot in robots
        D[robot.pos] = get(D, robot.pos, 0) + 1
    end

    # Now calculate the frequency of robots in each quadrant
    Q = fill(0, (2, 2))
    ym, xm = Tuple(GRID_SIZE)
    yd, xd = ym ÷ 2, xm ÷ 2

    for (k, v) in D
        y, x = Tuple(k)

        # Skip if in the middle
        (y == yd || x == xd) && continue

        # Determine which quadrant this index is in
        top = (yd <= y <= ym) + 1
        right = (xd <= x <= xm) + 1
        Q[top, right] += v
    end

    return prod(Q)
end

function part1(robots::Vector{Robot})
    next!(robots, 100)
    return safety_factor(robots)
end


### Part 2 ###

# Given a set of robots, calculate the amount of entropy in their positions
#
# Note that their entropy is on average ∼27.309%, with a minimum of ∼25.746%
# and a maximum of ∼27.811%.  We only really care about entropies of greater
# than 27.8% (std deviation ∼0.182%), because that's indicative of some kind
# of pattern in the positions of the robots.
function entropy(robots::Vector{Robot})
    # Construct BitMatrix
    M = falses(Tuple(GRID_SIZE))
    for robot in robots
        M[robot.pos + Index(1, 1)] = true
    end

    # Counts
    N = prod(size(M))
    n1 = sum(M)
    n0 = N - n1

    # Probabilities
    p0 = n0 / N
    p1 = n1 / N

    # Calculate entropy
    # https://en.wikipedia.org/wiki/Entropy_(information_theory)
    return -sum((p0, p1)) do p
        p > 0 || return 0
        p * log2(p)
    end
end


# The Christmas tree easter egg that appears as a pattern in the data has
# a greater entropy score than other configurations.
#
# I would have thought it would have a lower entropy score because it's more
# structured, but sure.
function part2(robots::Vector{Robot})
    n = 0
    while true
        entropy(robots) > 0.278 && return n
        next!(robots)
        n += 1
    end
end

function main()
    data = parse_input("data14.txt")

    # Part 1
    part1_solution = part1(deepcopy(data))
    @assert part1_solution == 214400550
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(deepcopy(data))
    @assert part2_solution == 8149 "$part2_solution ≠ 8149"
    println("Part 2: $part2_solution")
end

main()
