# I have a list of nodes (called "AA", "BB", and so on).  Each node is a valve, and each valve has a flow rate, and a list of nodes that you can access from the current node.  We have only 30 minutes to traverse these nodes and release as much pressure as possible, according to the valves' flow rate, and each valve/node that we visit takes 1 minute to walk to, and another minute if we need to open it.  Some nodes have a flow rate of zero, so presumably they do not need to be traversed.

using DataStructures
using OrderedCollections
using Combinatorics

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

# println(data)

#=function dfs!(valves::Valves, valve::Valve, visited::Set{String}, path::Stack{String}, pressure::Int, max_flow_rate::Int)
    # Add the current valve to the visited set and the path stack
    println(valve.name)
    push!(visited, valve.name)
    push!(path, valve.name)

    # Open the valve and add its flow rate to the total pressure
    pressure += max_flow_rate
    max_flow_rate += valve.flow_rate

    # Explore all the valves reachable from the current valve
    for next_valve in valve.connected_valves
        if next_valve ∉ visited
            pressure = dfs!(valves, valves[next_valve], visited, path, pressure, max_flow_rate)
        end
    end

    # Remove the current valve from the path stack
    pop!(path)
    return pressure
end=#

function dfs!(valves::Valves, node::Valve, time_remaining::Int, pressure_released::Int, path::Stack{String})
    # base case: if there is no time remaining, return the pressure released so far
    time_remaining == 0 && return pressure_released, path

    # base case: valve has no flow rate or has already been visited
    iszero(node.flow_rate) && return pressure_released, path

    # try opening the current valve and add the pressure release to the current total
    if node.open
        pressure_released += node.flow_rate * time_remaining
    end

    # add the current node to the path
    push!(path, node.name)

    # initialize the maximum pressure release found so far to the current pressure release
    max_pressure_released = pressure_released
    # initialize the path taken to reach the maximum pressure release to the current path
    # max_pressure_released_path = deepcopy(path)
    max_pressure_released_path = path

    # iterate over the neighbors of the current node
    for neighbour in node.connected_valves
        # add the current node to the path
        # push!(path, node.name)

        # Decrement the time remaining as we are now going to a new node
        time_remaining -= 1
        pressure_released_at_neighbour, path_at_neighbour = dfs!(valves, valves[neighbour], time_remaining, pressure_released, path)

        # if the neighbor has not been visited yet, recursively search from that node
        if !valves[neighbour].open
            # println(neighbour)
            valves[neighbour].open = true

             # subtract the time required to move to the neighbor and open the valve from the remaining time
            time_remaining -= 1
            pressure_released_at_neighbour, path_at_neighbour = dfs!(valves, valves[neighbour], time_remaining, pressure_released, path)

            # mark the neighbor as not visited so that it can be visited again in the future
            valves[neighbour].open = false
        end
    end

    # update the maximum pressure release found so far and the corresponding path if necessary
    if pressure_released_at_neighbour > max_pressure_released
        max_pressure_released = pressure_released_at_neighbour
        max_pressure_released_path = path_at_neighbour
    end

    # remove the current node from the path
    pop!(path)

    return max_pressure_released, max_pressure_released_path
end


function bfs(valves::Valves, start::Valve)
    Q = Queue{Tuple{String, Int, Int, Stack{String}, Set{String}}}()
    enqueue!(Q, (start.name, 30, 0, Stack{String}(), Set{String}()))
    max_pressure = 0
    max_path = Stack{String}()

    while !isempty(Q)
        current_valve_name, time_remaining, pressure_released, path, opened = dequeue!(Q)
        # println(current_valve_name)
        current_valve = valves[current_valve_name]
        # opened = deepcopy(opened)  # TODO: deepcopy?

        # base case: out of time
        if iszero(time_remaining)
            if pressure_released > max_pressure
                max_pressure = pressure_released
                max_path = path  # TODO: deepcopy?
            end
            continue
        end

        iszero(current_valve.flow_rate) && continue

        # open the valve and update the pressure released
        if current_valve.name ∈ opened
            pressure_released += current_valve.flow_rate * time_remaining
        else
            push!(opened, current_valve.name)
            time_remaining -= 1
        end

        # update the path
        push!(path, current_valve.name)

        # add all connected valves to queue
        for neighbour in current_valve.connected_valves
            enqueue!(Q, (neighbour, time_remaining - 1, pressure_released, path, opened))  # TODO: depecopy?
        end

        # remove the current valve from the path
        pop!(path)
    end

    return max_pressure, max_path
end

using GLPK, JuMP, HiGHS, Clp, Cbc, MosekTools

function linear_solve(valves::Valves)
    # model = Model(GLPK.Optimizer)
    # m = Model(GLPK.Optimizer)
    # m = Model(Cbc.Optimizer)
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    # m = Model(MosekTools.Optimizer)



    ## Take four
    ## Variables

    # At what minute the valve was opened
    @variable(model, T[keys(valves), 1:30], Bin)
    # Moved to valve at t minute
    @variable(model, M[keys(valves), 1:30], Bin)

    ## Constraints

    # You can only open a valve once.  Once opened, should not close
    for valve in keys(valves) # no opening more than once
        @constraint(model, sum(T[valve, :]) <= 1)
    end

    # You can only do one action per minute (move to valve _or_ open it)
    for t in 1:30
        @constraint(model, sum(T[:, t]) + sum(M[:, t]) <= 1)
    end

    for t in 2:30
        for (n, v) in valves
            # Only open a valve if you have moved to it in the minute immediately prior
            @constraint(model, T[n, t] <= M[n, t - 1])

            # Constrain what valves are accessible from connected tunnels
            @constraint(model, M[n, t] <= sum(M[n′, t - 1] + T[n′, t - 1] for (n′, v′) in valves if n ∈ v′.connected_valves))
        end
    end


    ## Initial conditions

    start = last(first(valves))
    # println(start)
    @constraint(model, sum(M[n, 1] for n in start.connected_valves) == 1)


    ## Objective function
    # @objective(m, Max, sum(v.flow_rate * (30 - t[n]) * x[n] for (n, v) in valves))
    # @objective(model, Max, sum(v.flow_rate .* T[n, 30] for (n, v) in valves))
    #=sum(valves) do (n, v)
        v.flow_rate * (30 - only(findall(==(1), T[n, :])))
    end=#
    # @objective(model, Max, sum(v.flow_rate * (30 - only(findall(==(1), T[n, :]))) for (n, v) in valves))

    # factor =
    # factor = SVector{30}(29:-1:0)
    #=factor = [29:-1:0;]
    OV = Dict()
    for (n, v) in valves
        push!(OV, n => factor .* v.flow_rate)
    end=#
    # @objective(model, Max, sum((v.flow_rate .* [29:-1:0;])'T[n, :] for (n, v) in valves))
    @objective(model, Max, sum(valves) do (n, v)
                   (v.flow_rate .* [29:-1:0;])'T[n, :]
               end)
    optimize!(model)



    for t in 1:30
        if sum(value.(T[:, t])) > 0
            for v in keys(valves)
                if value(T[v, t]) > 0
                    println("Period $t: opening valve $v")
                end
            end
        end
        if sum(value.(M[:, t])) > 0
            for v in keys(valves)
                if value(M[v, t]) > 0
                    println("Period $t: moving to valve $v")
                end
            end
        end
    end

    return solution_summary(model), model




    ## Take three

    @variable(m, x[keys(valves)], Bin)  # whether or not valve was opened
    @variable(m, t[keys(valves)], Int)  # At what minute was the valve opened

    # define the objective function
    @objective(m, Max, sum(v.flow_rate * (30 - t[n]) * x[n] for (n, v) in valves))

    # add time constraint
    @constraint(m, sum(t[n] for n in keys(valves)) <= 30)

    # add dependency contraints
    for (n, v) in valves
        for c in v.connected_valves
            @constraint(m, t[n] >= t[c])
        end
        end

    # add flow rate constraints; there is no need to open the valves that have zero flow rate
    #=for (n, v) in valves
        iszero(v.flow_rate) && @constraint(m, x[n] == 0)
    end=#



    # Take two
    @variable(m, x[keys(valves)], Bin)  # opened_valve
    # @variable(
    # @variable(m, y[keys(valves)], Bin)  # opened valve
    @variable(m, t[keys(valves)], Int)  # when was valve opened?

    # Define the objective function
    @objective(m, Max, sum(v.flow_rate * x[n] * t[n] for (n, v) in valves))

    # Constraint: time spent at each valve must be within the available time limit
    @constraint(m, sum(t[i] for i in keys(valve)) <= 30)

    # Constraint: only opena  valve if it has been visited
    @constraint(m, sum(t[n] for (n, v) in connected_valves) <= t[i])


    # Take one

    # This means that t[i] is equal to 1 if the node is not opened (x[i] is 0), and 2 if the node is opened (x[i] is 1).
    @variable(model, t[keys(valves)])
    @variable(model, x[keys(valves)], Bin)

    # Define the time required to visit (and potentially open) each node as a variable)
    for i in keys(valves)
        # 1 minute to walk to the node, plus an additional 1 minute if the node is opened
        @constraint(model, t[i] == 1 + (1 - x[i]))
    end

    # add the time constraint
    @constraint(model, sum(t[i] * x[i] for i in keys(valves)) <= 30)

    # Add the flow rate constraints
    for j in keys(valves)
        # @constraint(model,  <= sum(x[i] for i in nodes if i ∈ valves[i].connected_valves))
    end

    # Set the objective function
    @objective(model, Max, sum(valves[i].flow_rate * x[i] * (30 - t[i]) for i in keys(valves)))

    return model
end


calc_pressure_released(valves::Valves, time_limit::Int) =
    sum(v.flow_rate * (time_limit - v.opened_at) * v.open for (_, v) in valves)

function main(valves::Valves)
    time_limit = 30
    mins = 2  # First move (one-indexed) is taken by moving to the first valve

    #=for (n, m) in (("DD", 2), ("BB", 5), ("JJ", 9), ("HH", 17), ("EE", 21), ("CC", 24))
        valves[n].open = true
        valves[n].opened_at = m
    end=#

    # return calc_pressure_released(valves, time_limit)

    # The aim is to start at the valve that maximises flow rate and number of connecting
    # valves, and see where that takes us
    valves = sort(valves, by = name -> (length(valves[name].connected_valves), valves[name].flow_rate), rev = true)
    inefficient = Set{String}(name for (name, v) in valves if iszero(v.flow_rate))
    # filter!(p -> !iszero(last(p).flow_rate), valves)

    return linear_solve(valves)
    return valves


    # start the search at valve AA with 30 minutes of time remaining
    path = Stack{String}()
    max_pressure_released, path = bfs(valves, last(first(valves)))
    # max_pressure_released, path = dfs!(valves, last(first(valves)), 30, 2, path)
    return max_pressure_released, path


    visited, path = Set{String}(), Stack{String}()
    return dfs!(valves, last(first(valves)), visited, path, 0, 0)

    #=stack = Stack{Tuple{Valve, Int}}()
    name, valve = first(valves)
    push!(stack, (valve, 3))
    opened = Set{String}()
    while !isempty(stack)
        valve, mins = pop!(stack)
        println("$mins: $valve, $opened")
        if !valve.open && !iszero(valve.flow_rate)
            push!(opened, name)
            valve.opened_at = mins
            mins += 1
        end

        mins + 1 > time_limit && break
        mins += 1
        mins + 1 > time_limit && break

        for vn in valve.connected_valves
            next_valve = valves[vn]
            push!(stack, (next_valve, mins))
        end
    end
    return calc_pressure_released(valves, time_limit)

    while mins <= time_limit
        println("$mins: $valve, $opened")
        # if name ∉ opened
        if !valve.open && valve.name ∉ inefficient
            push!(opened, name)
            valve.opened_at = mins
            mins += 1
        end
        # name = findfirst(v -> v.name ∈ valve.connected_valves && v.name ∉ opened, valves)
        # name = findfirst(v -> v.name ∈ valve.connected_valves && !v.open, valves)
        name = valve.connected_valves[findfirst(n -> !valves[n].open, valve.connected_valves)]
        # name = new_name
        valve = valves[name]
        mins += 1
    end
    return calc_pressure_released(valves, time_limit)=#




    _, start_valve = first(valves)
    stack = [(start_valve, 0, 0, 0)]
    max_flow_rate = 0
    visited = Set()

    while !isempty(stack)
        valve, flow_rate, total_flow, time_elapsed = pop!(stack)
        println("$(valve.name)")

        valve.name ∈ visited && continue
        push!(visited, valve.name)

        max_flow_rate = max(max_flow_rate, flow_rate)

        if time_elapsed + 1 > time_limit
            continue
        end

        for vn in valve.connected_valves
            next_valve = valves[vn]
            # flow_rate += sum(valves[v].flow_rate for v in visited) + next_valve.flow_rate
            total_flow += flow_rate
            flow_rate += next_valve.flow_rate
            time_elapsed += 1
            push!(stack, (next_valve, flow_rate, total_flow, time_elapsed))
            # sum(v.flow_rate * (time_limit - v.opened_at) for (_, v) in valves)
        end
    end
    return max_flow_rate



    opened = Set{String}()
    name, valve = first(valves)
    while mins <= time_limit
        println("$mins: $valve, $opened")
        # if name ∉ opened
        if !valve.open && valve.name ∉ inefficient
            push!(opened, name)
            valve.opened_at = mins
            mins += 1
        end
        # name = findfirst(v -> v.name ∈ valve.connected_valves && v.name ∉ opened, valves)
        # name = findfirst(v -> v.name ∈ valve.connected_valves && !v.open, valves)
        name = valve.connected_valves[findfirst(n -> !valves[n].open, valve.connected_valves)]
        # name = new_name
        valve = valves[name]
        mins += 1
    end
    return calc_pressure_released(valves, time_limit)



    # paths_tried = Vector{Vector{String}}[String[] for _ in 1:time_limit]
    paths_tried = Vector{Vector{String}}()
    # pᵢ = 1
    while true
        opened = Set{String}()
        these_valves = deepcopy(valves)
        path = String[]
        mins = 2  # first move (one-indexed) is taken by moving to the first valve
        name, valve = first(these_valves)
        while mins <= time_limit
            println("$mins: $valve, $opened")
            if name ∉ opened
                push!(opened, name)
                mins += 1
            end
            # new_name = findfirst(v -> v.name ∈ valve.connected_valves && v.name ∉ opened, valves)
            new_name = valve.connected_valves[findfirst(n -> n ∉ opened, valve.connected_valves)]
            if isnothing(new_name)
                # mins -= 1
                push!(paths_tried, )
            else
                name = new_name
                if vcat(path, name) ∈ paths_tried
                    break
                end
                valve = valves[name]
                mins += 1
            end
        end
        # Return the result if we found one
        length(last(paths_tried)) == time_limit && return calc_pressure_released(valves, time_limit)
        pᵢ += 1
    end

    return calc_pressure_released(valves, time_limit)
end

println(main(data))
