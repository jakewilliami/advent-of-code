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

function n_in_row(robots::Vector{Robot}, n::Int)
    positions = Index[robot.pos for robot in robots]
    for i in Index(0, 0):GRID_SIZE
        y, x = Tuple(i)
        if all(Index(y, x + j) ∈ positions for j in 0:(n - 1))
            return true
        end
    end
    return false
end

# This is slow, probably because `n_in_row` is poorly implemented, but it
# gets the right answer.  The Christmas tree easter egg that appears as a
# pattern in the data has a surrounding border, so we look for a pattern
# with a straight line.  The boarder is 30- something wide, so this seems
# to do the trick.
function part2(robots::Vector{Robot})
    n = 0
    while true
        n_in_row(robots, 30) && return n
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
