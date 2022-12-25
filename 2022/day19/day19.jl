# I have 24 minutes to open as many geodes as possible.  I require the following resources: ore, clay, and obsidian.  I have three types of robot that I can make, each specialising in the type of resource it can obtain (e.g., the ore robot can collect ore).  Each robot can collect one of its resource per minute.  It takes one minute to make each robot, but I can make them simultaneously.  Each robot costs a certain amount of ore, clay, and obsidian to make.  There is also a geode robot that can crack geodes, which costs a certain amount of resource to make.  I start with one ore.  I must determine what robots to build and how to spend my resources in order to maximise the number of geodes I can crack into.
# Just day 16 all over again...
# Not super proud of solution, after spending too much time on linear programming agian, had the data structure I had and worked with it, but is a bit gross with all the get fields set fiesll etrc, shoudlnve used dicts

using Combinatorics
using DataStructures

# f = "data19.txt"
f = "test.txt"

struct Cost
    ore::Int
    clay::Int
    obsidian::Int
end

struct Blueprint
    n::Int
    ore::Cost
    clay::Cost
    obsidian::Cost
    geode::Cost
end

function Base.parse(::Type{Cost}, s::AbstractString)
    re = r"(\d+)\s(\w+)"
    costs = Dict{Symbol, Int}(x => 0 for x in (:ore, :clay, :obsidian))
    for m in eachmatch(re, s)
        n_str, x_str = m.captures
        n = parse(Int, n_str)
        x = Symbol(x_str)
        costs[x] += n
    end

    return Cost(costs[:ore], costs[:clay], costs[:obsidian])
end

re = r"Blueprint (\d+): Each ore robot costs (.*). Each clay robot costs (.*). Each obsidian robot costs (.*). Each geode robot costs (.*)."
data = readlines(f)
data = Blueprint[]
for line in eachline(f)
    m = match(re, line)
    n_str, ore_cost_str, clay_cost_str, obsidian_cost_str, geode_cost_str = m.captures
    n = parse(Int, n_str)
    ore_cost, clay_cost, obsidian_cost, geode_cost = parse.(Cost, (ore_cost_str, clay_cost_str, obsidian_cost_str, geode_cost_str))
    blueprint = Blueprint(n, ore_cost, clay_cost, obsidian_cost, geode_cost)
    push!(data, blueprint)
end

println(data)

using GLPK, JuMP, HiGHS#, Clp, Cbc, MosekTools

function linear_solve_old_old(blueprint::Blueprint)
    model = Model(GLPK.Optimizer)

    # Ore is finite
    @variable(model, ore_available, Int)
    @variable(model, clay_available, Int)
    @variable(model, obsidian_available, Int)
    @variable(model, geode_available, Int)

    # Number of material collecting robots
    @variable(model, x_ore >= 0, Int)
    @variable(model, x_clay >= 0, Int)
    @variable(model, x_obsidian >= 0, Int)
    @variable(model, x_geode >= 0, Int)


    @objective(model, Max, x_geode)

    # Constraints
    # @variable(m, t[1:24], Int)  # when was valve opened?

    # Time limit
    @constraint(model, x_ore + x_clay + x_obsidian + x_geode <= 24)

    # Ore collection constraints

    # Robot costs
    ore_cost, clay_cost, obsidian_cost, geode_cost = blueprint.ore_cost, blueprint.clay_cost, blueprint.obsidian_cost, blueprint.geode_cost
    @constraint(model, ore_cost.ore * x_ore + ore_cost.clay * x_clay + ore_cost.obsidian * x_obsidian + ore_cost.geode * x_geode <= ore_available)  # Ore robot cost
    @constraint(model, clay_cost.ore * x_ore + clay_cost.clay * x_clay + clay_cost.obsidian * x_obsidian + clay_cost.geode * x_geode <= clay_available)  # Clay robot cost
    @constraint(model, obsidian_cost.ore * x_ore + obsidian_cost.clay * x_clay + obsidian_cost.obsidian * x_obsidian + obsidian_cost.geode * x_geode <= obsidian_available)  # Obsidian robot cost
    @constraint(model, geode_cost.ore * x_ore + geode_cost.clay * x_clay + geode_cost.obsidian * x_obsidian + geode_cost.geode * x_geode <= geode_available)  # Geode robot cost

    optimize!(model)

    return value(x_geode)
end

function linear_solve_old(blueprint::Blueprint)
    model = Model(GLPK.Optimizer)
    # set_silent(model)
    # model = Model(HiGHS.Optimizer)


    # Number of each robot built at each minute
    @variable(model, ore_robots[1:24] >= 0, Int)
    @variable(model, clay_robots[1:24] >= 0, Int)
    @variable(model, obsidian_robots[1:24] >= 0, Int)
    @variable(model, geode_robots[1:24] >= 0, Int)

    # Resources
    @variable(model, ore_available, Int)
    @variable(model, clay_available, Int)
    @variable(model, obsidian_available, Int)
    @variable(model, geodes_open, Int)

    # @variable(model, production[1:24, (:ore, :clay, :obsidian, :geode)])  # 24 minutes, 4 resources
    @variable(model, production[1:24, (:ore, :clay, :obsidian)])

    # Objective function
    # @objective(model, Max, sum((24 - i + 1) * geode_robots[i] for i in 1:24))
    # @objective(model, Max, production[24, :geode])
    @objective(model, Max, geodes_open)

    # Resources
    @constraint(model, ore_robots[1] == true)  # You can start with one ore robot
    @constraint(model, production[1, :ore] == 1)  # Your first step is one ore robot collecting one resource
    # @constraint(model, [i in 1:24], ore_robot)  # Factory capacity
    # @constraint(model, [i in 1:24], ore_robots[i] * 4)  # Ore constraints

    # Number of material collecting robots
    # @variable(model, x_ore >= 0, Int)
    # @variable(model, x_clay >= 0, Int)
    # @variable(model, x_obsidian >= 0, Int)
    # @variable(model, x_geode >= 0, Int)

    # Constraints
    # @variable(m, t[1:24], Int)  # when was valve opened?
    D = Dict{Symbol, Vector{VariableRef}}(:ore => ore_robots, :clay => clay_robots, :obsidian => obsidian_robots, :geode => geode_robots)
    C = Dict{Symbol, Cost}(:ore => blueprint.ore_cost, :clay => blueprint.clay_cost, :obsidian => blueprint.obsidian_cost, :geode => blueprint.geode_cost)
    B = Dict{Symbol, VariableRef}(:ore => ore_available, :clay => clay_available, :obsidian => obsidian_available)
    for i in 2:24, m in (:ore, :clay, :obsidian)
        # Define the production to be the sum of all previous steps; TODO (check this is right)
        @constraint(model, production[i, m] == sum(D[m][j] for j in (i - 1):-1:1))

        # Define each robot cost
        @constraint(model, ore_available >= C[m].ore)
        @constraint(model, clay_available >= C[m].clay)
        @constraint(model, obsidian_available >= C[m].obsidian)
        # @constraint(model, geode_available >= C[m].geode_cost)

        # Get more ore this turn
        # @constraint(model, B[m] == B[m] + sum(D[m][j] for j in (i - 1):-1:1))
        @constraint(model, B[m] == B[m] + production[i - 1, m])
    end

    for i in 2:24
        # Get geodes TODO
        @constraint(model, geodes_open == geodes_open + sum(geode_robots[j] for j in (i - 1):-1:1))
    end


    for i in 2:24, m in (:ore, :clay, :obsidian, :geode)
        # Use up a resource to create a robot TODO
        @constraint(model, production[i, m] == production[i - 1, m] - )
    end

    # Time limit
    # @constraint(model, x_ore + x_clay + x_obsidian + x_geode <= 24)
    # @constraint(model, )

    # Ore collection constraints

    # Robot costs
    ore_cost, clay_cost, obsidian_cost, geode_cost = blueprint.ore_cost, blueprint.clay_cost, blueprint.obsidian_cost, blueprint.geode_cost
    @constraint(model, ore_cost.ore * x_ore + ore_cost.clay * x_clay + ore_cost.obsidian * x_obsidian + ore_cost.geode * x_geode <= ore_available)  # Ore robot cost
    @constraint(model, clay_cost.ore * x_ore + clay_cost.clay * x_clay + clay_cost.obsidian * x_obsidian + clay_cost.geode * x_geode <= clay_available)  # Clay robot cost
    @constraint(model, obsidian_cost.ore * x_ore + obsidian_cost.clay * x_clay + obsidian_cost.obsidian * x_obsidian + obsidian_cost.geode * x_geode <= obsidian_available)  # Obsidian robot cost
    @constraint(model, geode_cost.ore * x_ore + geode_cost.clay * x_clay + geode_cost.obsidian * x_obsidian + geode_cost.geode * x_geode <= geode_available)  # Geode robot cost

    optimize!(model)

    return value(x_geode)
end

function linear_solve_oldish(blueprint::Blueprint)
    model = Model(GLPK.Optimizer)
    # set_silent(model)
    # model = Model(HiGHS.Optimizer)

    # Variable: time
    @variable(model, t >= 0, Int)

    # Variables: number of robots to build
    @variable(model, x1 >= 0, Int)  # ore
    @variable(model, x2 >= 0, Int)  # clay
    @variable(model, x3 >= 0, Int)  # obsidian
    @variable(model, x4 >= 0, Int)  # geode

    # Variables: amount of resource
    @variable(model, y1 >= 0, Int)  # ore
    @variable(model, y2 >= 0, Int)  # clay
    @variable(model, y3 >= 0, Int)  # obsidian

    # Variable: number of geodes cracked open
    @variable(model, geodes_opened >= 0, Int)


    # Objective function
    @objective(model, Max, geodes_opened)

    # Constraints: resource collection constraints
    @constraint(model, x1 <= y1)
    @constraint(model, x2 <= y2)
    @constraint(model, x3 <= y3)
    @constraint(model, x4 <= geodes_opened)

    # Constraints: cost of resources
    ore_cost, clay_cost, obsidian_cost, geode_cost = blueprint.ore_cost, blueprint.clay_cost, blueprint.obsidian_cost, blueprint.geode_cost
    @constraint(model, y1 <= (ore_cost.ore * x1 + ore_cost.clay * x2 + ore_cost.obsidian * x3))
    @constraint(model, y2 <= (clay_cost.ore * x1 + clay_cost.clay * x2 + clay_cost.obsidian * x3))
    @constraint(model, y3 <= (obsidian_cost.ore * x1 + obsidian_cost.clay * x2 + obsidian_cost.obsidian * x3))
    @constraint(model, geodes_opened <= (geode_cost.ore * x1 + geode_cost.clay * x2 + geode_cost.obsidian * x3))

    # Constraint: geode produce
    @constraint(model, geodes_open == geodes_open + x4)

    # Constraint: Time
    @constraint(model, t <= 24)

    # Find optimal solution
    optimize!(model)

    return value(geodes_open)
end

#=
Let's define the following variables:

x_o: the number of ore robots we build
x_c: the number of clay robots we build
x_o_b: the number of obsidian robots we build
x_g: the number of geode robots we build

We want to maximize the number of geode robots we build (x_g) within 24 minutes.

The constraints are as follows:

    The number of ore robots we build must be less than or equal to the number of ore we have available: x_o <= number of ore
    The number of clay robots we build must be less than or equal to the number of clay we have available: x_c <= number of clay
    The number of obsidian robots we build must be less than or equal to the number of obsidian we have available: x_o_b <= number of obsidian

In addition, we need to consider the time it takes to build each type of robot and the resources required to build them. For example, if we want to build an ore robot, it will take 1 minute and cost 2 ore (according to blueprint 2). We need to account for this in our constraints.

The constraints for building robots can be expressed as follows:

    The number of ore robots we can build is limited by the time and resources available: x_o <= (24 minutes - time spent building other robots) / time to build an ore robot and x_o <= (number of ore - resources spent building other robots) / cost of an ore robot in ore
    The number of clay robots we can build is limited by the time and resources available: x_c <= (24 minutes - time spent building other robots) / time to build a clay robot and x_c <= (number of clay - resources spent building other robots) / cost of a clay robot in clay
    The number of obsidian robots we can build is limited by the time and resources available: x_o_b <= (24 minutes - time spent building other robots) / time to build an obsidian robot and x_o_b <= (number of obsidian - resources spent building other robots) / cost of an obsidian robot in obsidian
    The number of geode robots we can build is limited by the time and resources available: x_g <= (24 minutes - time spent building other robots) / time to build a geode robot and x_g <= (number of geode - resources spent building other robots) / cost of a geode robot in geode

Finally, we need to consider the time it takes for each robot to collect its respective resource. For example, if we have 2 ore robots, they will collect 2 ore per minute. We need to account for this in our constraints as well.

The constraints for resource collection can be expressed as follows:

    The number of ore we can collect is limited by the number of ore robots we have: number of ore <= x_o * ore collected per minute
    The number of clay we can collect is limited by the number of clay robots we have: number of clay <= x_c * clay collected per minute
    The number of obsidian we can collect is limited by the number of obsidian robots we have: number of obsidian <= x_o_b * obsidian collected per minute
    The number of geode we can collect is limited by the number of geode robots we have: number of geode <= x_g * geode collected per minute

Putting it all together, the linear programming problem can be expressed as follows:

Maximize x_g

=============================================

We can represent the problem as a linear program where the decision variables are the number of ore-collecting robots ($x_1$), clay-collecting robots ($x_2$), obsidian-collecting robots ($x_3$), and geode-collecting robots ($x_4$) that are built at each minute. The objective is to maximize the number of geode-collecting robots built, subject to the constraints that the number of each type of robot built at each minute is non-negative and the total cost of the robots built at each minute does not exceed the available resources.

The constraints can be expressed as follows:

$$x_1 \ge 0, x_2 \ge 0, x_3 \ge 0, x_4 \ge 0$$

$$x_1 \cdot cost_{ore,1} + x_2 \cdot cost_{clay,1} + x_3 \cdot cost_{obsidian,1} + x_4 \cdot cost_{geode,1} \le resources_{ore,1}$$

$$x_1 \cdot cost_{ore,2} + x_2 \cdot cost_{clay,2} + x_3 \cdot cost_{obsidian,2} + x_4 \cdot cost_{geode,2} \le resources_{ore,2}$$

$$...$$

$$x_1 \cdot cost_{ore,24} + x_2 \cdot cost_{clay,24} + x_3 \cdot cost_{obsidian,24} + x_4 \cdot cost_{geode,24} \le resources_{ore,24}$$

Where $cost_{ore,t}$ is the cost of building an ore-collecting robot at minute $t$, $resources_{ore,t}$ is the number of ore resources available at minute $t$, and so on for the other resource types.

The objective function is:

$$\max x_4$$

The linear program can then be expressed as follows:

$$\begin{aligned} \text{maximize} \qquad & x_4 \ \text{subject to} \qquad & x_1 \ge 0 \ & x_2 \ge 0 \ & x_3 \ge 0 \ & x_4 \ge 0 \ & x_1 \cdot cost_{ore,1} + x_2 \cdot cost_{clay,1} + x_3 \cdot cost_{obsidian,1} + x_4 \cdot cost_{geode,1} \le resources_{ore,1} \ & x_1 \cdot cost_{ore,2} + x_2 \cdot cost_{clay,2} + x_3 \cdot cost_{obsidian,2} + x_4 \cdot cost_{geode,2} \le resources_{ore,2} \ & ... \ & x_1 \cdot cost_{ore,24} + x_2 \cdot cost_{clay,24} + x_3 \cdot cost_{obsidian,24} + x_4 \cdot cost_{geode,24} \le resources_{ore,24} \ \end{aligned}$$
=#

function linear_solve(blueprint::Blueprint)
    model = Model(GLPK.Optimizer)
    # set_silent(model)
    # model = Model(HiGHS.Optimizer)

    # @variable(model, t >= 0, Int)

    # Variables: number of robots to build
    @variable(model, x1 >= 0, Int)  # ore
    @variable(model, x2 >= 0, Int)  # clay
    @variable(model, x3 >= 0, Int)  # obsidian
    @variable(model, x4 >= 0, Int)  # geode
    # @variable(model, x1[1:24] >= 0, Int)  # ore
    # @variable(model, x2[1:24] >= 0, Int)  # clay
    # @variable(model, x3[1:24] >= 0, Int)  # obsidian
    # @variable(model, x4[1:24] >= 0, Int)  # geode

    # @variable(model, y1[1:24] >= 0, Int)
    # @variable(model, y2[1:24] >= 0, Int)
    # @variable(model, y3[1:24] >= 0, Int)

    # Number of geodes at minutes t
    @variable(model, w[1:24], Int)

    @variable(model, resources[(:ore, :clay, :obsidian), 1:24])

    # cost = Dict{Symbol, Int}(
        # :ore
    # )

    # @variable(model, cost[1:24])
    # TODO: base case (start with robot)
    # @constraint(model, x1 == 1)
    # @constraint(model, x[1] == 1)
    @constraint(model, resources[:ore, 1] == 1)

    # @objective(model, Max, x4)
    @objective(model, Max, w[24])

    # robot type => something
    D = Dict(:ore => x1, :clay => x2, :obsidian => x3, :geode => x4)
    # TODO: case where i == 1
    for i in 2:24
        for rt in (:ore, :clay, :obsidian)  # robot type
            # @constraint(model, <= resources[m, i])
            cost = getfield(blueprint, rt)
            @constraint(model, resources[rt, i] <= getfield(cost, rt))
            @constraint(model, resources[rt, i] == (D[rt] + resources[rt, i - 1]))
        end
    end

    # for i in 2:24
# end

x1 · cost ore,1 + x2 · costclay,1 + x3 · costobsidian,1 + x4 · costgeode,1 ≤ resourcesore,1


    @constraint(model, w[1] <= x4)
    for i in 2:24
        # TODO: define const functions like this that define how much resource we get from each robot
        @constraint(model, w[i] == (w[i - 1] + x4))
    end
end

mutable struct Resources
    ore::Int
    clay::Int
    obsidian::Int
end

mutable struct Robots
    ore::Int
    clay::Int
    obsidian::Int
    geode::Int
end

mutable struct State
    resources::Resources
    robots::Robots
    geodes_opened::Int
    time_remaining::Int
end

function collect_resources!(S::State)
    # resource_names = (:ore, :clay, :obsidian)
    # for rₙ in resource_names
        # setfield!(S.resources, rₙ, getfield(S.reources, rₙ) + getfield(S.robots, rₙ))
    # end
    S.resources.ore += S.robots.ore
    S.resources.clay += S.robots.clay
    S.resources.obsidian += S.robots.obsidian
    S.geodes_opened += S.robots.geode
    return S
end

function increment_time!(S::State)
    S.time += 1
    return S
end

function can_build(R::Resources, cost::Cost)
    # buildable_resource_names = (:ore, :clay, :obsidian)
    # for rₙ in buildable_resource_names
        # getfield(R, rₙ) >= getfield(cost, rₙ) || return false
    # end
    R.ore >= cost.ore || return false
    R.clay >= cost.clay || return false
    R.obsidian >= cost.obsidian || return false
    return true
end

function build!(S::State, cost::Cost, robot::Symbol)
    # buildable_resource_names = (:ore, :clay, :obsidian)
    # for rₙ in buildable_resource_names
        # println("$rₙ: subtracting $(getfield(cost, rₙ)) from $(getfield(S.resources, rₙ))")
        # setfield!(S.resources, rₙ, getfield(S.resources, rₙ) - getfield(cost, rₙ))
    # end
    S.resources.ore -= cost.ore
    S.resources.clay -= cost.clay
    S.resources.obsidian -= cost.obsidian
    setfield!(S.robots, robot, getfield(S.robots, robot) + 1)
    return S
end

function queue_available!(Q::Queue{State}, S::State, blueprint::Blueprint)
    # Base case: simplu collect resources
    S′ = deepcopy(S)
    S′.time_remaining -= 1
    enqueue!(Q, S′)

    # Queue different combinations of building robots
    robot_names = (:ore, :clay, :obsidian, :geode)
    buildable = Dict{Symbol, Bool}(rₙ => can_build(S.resources, getfield(blueprint, rₙ)) for rₙ in robot_names)
    robot_combinations = Base.Iterators.flatten(multiset_combinations(robot_names, i) for i in first(axes(robot_names)))
    # Need to check for all combinations what we can queue, as we can build multiple at once; should only be 15 or so
    for robots in robot_combinations
        all(buildable[rₙ] for rₙ in robots) || continue
        S′ = deepcopy(S)
        for rₙ in robots
            cost = getfield(blueprint, rₙ)
            build!(S′, cost, rₙ)
            S′.time_remaining -= 1
        end
        enqueue!(Q, S′)
    end
end

function optimise_blueprint(blueprint::Blueprint)
    max_geodes = 0
    S = State(Resources(0, 0, 0), Robots(1, 0, 0, 0), 0, 24)  # Start with 1 ore-collecting robot
    Q = Queue{State}()
    seen_states = Set{State}()
    enqueue!(Q, S)
    while !isempty(Q)
        S = dequeue!(Q)

        # Set max geodes cracked
        max_geodes = max(max_geodes, S.geodes_opened)

        # Stop if we have reached the time limit
        iszero(S.time_remaining) && continue

        # Something
        # Co, ore_cost,
        # Cc, clay_cost,
        # Co1, obsidian_cost_ore,
        # Co2, obsidian_cost_clay,
        # Cg1, geode_cost_ore,
        # Cg2, geode_cost_clay,
        # ores = Tuple(getfield(S.resources, rₙ) for rₙ in (:ore, :clay, :obsidian, :geode))

        #=most_ore = maximum((blueprint.ore.ore, blueprint.clay.ore, blueprint.obsidian.ore, blueprint.geode.ore))
        if S.robots.ore >= most_ore
            S.robots.ore = most_ore
        end
        if S.robots.clay >= blueprint.obsidian.clay
            S.robots.clay = blueprint.obsidian.clay
        end
        if S.robots.obsidian >= blueprint.geode.clay
            S.robots.obsidian = blueprint.geode.clay
        end
        if S.resources.ore >= (S.time_remaining * most_ore - S.robots.ore * (S.time_remaining - 1))
            S.resources.ore = S.time_remaining * most_ore - S.robots.ore * (S.time_remaining - 1)
        end
        if S.resources.clay >= (S.time_remaining * blueprint.obsidian.clay  - S.robots.clay * (S.time_remaining - 1))
            S.resources.clay = S.time_remaining * blueprint.obsidian.clay  - S.robots.clay * (S.time_remaining - 1)
        end
        if S.resources.obsidian >= (S.time_remaining * blueprint.geode.clay - S.robots.obsidian * (S.time_remaining - 1))
            S.resources.obsidian = S.time_remaining * blueprint.geode.clay - S.robots.obsidian * (S.time_remaining - 1)
        end=#

        # Skip if we have seen this state
        S ∈ seen_states && continue
        push!(seen_states, S)
        return

        #=if iszero(mod(length(seen_states), 1000000))
            println(S.time_remaining, " ", max_geodes, " ", length(seen_states))
        end
        @assert(S.resources.ore >= 0 && S.resources.clay >= 0 && S.resources.obsidian >= 0 && S.geodes_opened >= 0, S)

        S′ = State(
            Resources(S.resources.ore + S.robots.ore, S.resources.clay + S.robots.clay, S.resources.obsidian + S.robots.obsidian),
            deepcopy(S.robots), S.geodes_opened + S.robots.geode, S.time_remaining - 1
        )
        enqueue!(Q, S′)

        # queue_available!(Q, S, blueprint)

        if S.resources.obsidian >= blueprint.ore.ore
            S′ = State(
                Resources(S.resources.ore - blueprint.ore.ore + S.robots.ore, S.resources.clay + S.robots.clay, S.resources.obsidian + S.robots.obsidian),
                Robots(S.robots.ore + 1, S.robots.clay, S.robots.obsidian, S.robots.geode),
                S.geodes_opened + S.robots.geode, S.time_remaining - 1
            )
            enqueue!(Q, S′)
        end
        if S.resources.ore >= blueprint.clay.ore
            S′ = State(
                Resources(S.resources.ore - blueprint.clay.ore + S.robots.ore, S.resources.clay + S.robots.clay, S.resources.obsidian + S.robots.obsidian),
                Robots(S.robots.ore, S.robots.clay + 1, S.robots.obsidian, S.robots.geode),
                S.geodes_opened + S.robots.geode, S.time_remaining - 1
            )
            enqueue!(Q, S′)
        end
        if S.resources.ore >= blueprint.obsidian.ore && S.resources.clay >= blueprint.obsidian.clay
            S′ = State(
                Resources(S.resources.ore - blueprint.obsidian.ore + S.robots.ore, S.resources.clay - blueprint.obsidian.clay + S.robots.clay, S.resources.obsidian + S.robots.obsidian),
                Robots(S.robots.ore, S.robots.clay, S.robots.obsidian + 1, S.robots.geode),
                S.geodes_opened + S.robots.geode, S.time_remaining - 1
            )
            enqueue!(Q, S′)
        end
        if S.resources.ore >= blueprint.geode.ore && S.resources.clay >= blueprint.geode.clay
            S′ = State(
                Resources(S.resources.ore - blueprint.geode.ore + S.robots.ore, S.resources.clay - blueprint.geode.clay + S.robots.clay, S.resources.obsidian + S.robots.obsidian),
                Robots(S.robots.ore, S.robots.clay, S.robots.obsidian, S.robots.geode + 1),
                S.geodes_opened + S.robots.geode, S.time_remaining - 1
            )
            enqueue!(Q, S′)
        end=#


        # Collect resources with the current robots we have
        collect_resources!(S)

        # Queue any combination of new robots we can make
        queue_available!(Q, S, blueprint)
    end

    return max_geodes
end

function main(data)
    return linear_solve(data[1])

    # return optimise_blueprint(data[1])
end

println(main(data))
