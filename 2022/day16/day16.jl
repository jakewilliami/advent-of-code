# I have a list of nodes (called "AA", "BB", and so on).  Each node is a valve, and each valve has a flow rate, and a list of nodes that you can access from the current node.  We have only 30 minutes to traverse these nodes and release as much pressure as possible, according to the valves' flow rate, and each valve/node that we visit takes 1 minute to walk to, and another minute if we need to open it.  Some nodes have a flow rate of zero, so presumably they do not need to be traversed.


using OrderedCollections
using JuMP, HiGHS

f = "data16.txt"
f = "test.txt"
# TODO: make name a symbol
mutable struct Valve
    name::String
    flow_rate::Int
    connected_valves::Vector{String}
    open::Bool
    opened_at::Int
end

# re = r"Valve (\w+) has flow rate=(\d+); tunnel(?:s)? lead(?:s)? to valve(?:s)? (\w+)(,\s+\w+)*"
# re = r"Valve (\w+) has flow rate=(\d+); tunnel(?:s)? lead(?:s)? to valve(?:s)? \b([^,\s]+)\b(?:,\s*\b([^,\s]+)\b)*"
re = r"Valve (\w+) has flow rate=(\d+); tunnel(?:s)? lead(?:s)? to valve(?:s)? (.*)"
# re2 = r""

const Valves = OrderedDict{String, Valve}

data = Valves()
for line in eachline(f)
    name, rate_str, connected_str = match(re, line).captures
    flow_rate = parse(Int, rate_str)
    # connected_valves = isnothing(connected_str) ? String[] : split(connected_str, ", ")[2:end]
    connected_valves = split(connected_str, ", ")
    # pushfirst!(connected_valves, connected_first)
    valve = Valve(name, flow_rate, connected_valves, false, 0)
    data[name] = valve
end


function linear_solve!(valves::Valves, time_limit::Int)
    model = Model(HiGHS.Optimizer)
    set_silent(model)


    ## Variables

    # At what minute the valve was opened
    @variable(model, T[keys(valves), 1:time_limit], Bin)
    # Moved to valve at t minute
    @variable(model, M[keys(valves), 1:time_limit], Bin)


    ## Constraints

    # You can only open a valve once.  Once opened, should not close
    for valve in keys(valves) # no opening more than once
        @constraint(model, sum(T[valve, :]) <= 1)
    end

    # You can only do one action per minute (move to valve _or_ open it)
    for t in 1:time_limit
        @constraint(model, sum(T[:, t]) + sum(M[:, t]) <= 1)
    end

    for t in 2:time_limit
        for (n, v) in valves
            # Only open a valve if you have moved to it in the minute immediately prior
            @constraint(model, T[n, t] <= M[n, t - 1])

            # Constrain what valves are accessible from connected tunnels
            @constraint(model, M[n, t] <= sum(M[n′, t - 1] + T[n′, t - 1] for (n′, v′) in valves if n ∈ v′.connected_valves))
        end
    end


    ## Initial conditions

    start = last(first(valves))
    @constraint(model, sum(M[n, 1] for n in start.connected_valves) == 1)


    ## Objective function

    @objective(model, Max, sum(valves) do (n, v)
                   (v.flow_rate .* [(time_limit - 1):-1:0;])'T[n, :]
               end)
    optimize!(model)


    ## Set solution in valves dict

    for t in 1:time_limit
        println(value.(T[:, t]))
        n = findfirst(==(1), [value(x) for x in T[:, t]])
        if !isnothing(n)
            v = valves[n]
            println("Period $t: opening valve $n")
            v.open = true
            v.opened_at = t
        end

        n = findfirst(==(1), [value(x) for x in M[:, t]])
        if !isnothing(n)
            println("Period $t: moving to valve $n")
        end
    end

    return solution_summary(model), model
end


calc_pressure_released(valves::Valves, time_limit::Int) =
    sum(v.flow_rate * (time_limit - v.opened_at) * v.open for (_, v) in valves)

function main(valves::Valves)
    time_limit = 30
    mins = 2  # First move (one-indexed) is taken by moving to the first valve

    # Sort by valve that maximises flow rate and number of connecting tunnels
    valves = sort(valves, by = name -> (length(valves[name].connected_valves), valves[name].flow_rate), rev = true)

    println(calc_pressure_released(valves, time_limit))
    println([v.opened_at for (_, v) in valves])
    linear_solve!(valves, time_limit)
    println(valves)

    println([v.opened_at for (_, v) in valves])
    println(calc_pressure_released(valves, time_limit))
end

println(main(data))
