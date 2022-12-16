using DataStructures
using OrderedCollections
using Combinatorics

f = "data16.txt"
f = "test.txt"

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

    # try opening the current valve and add the pressure release to the current total
    pressure_released += node.flow_rate * time_remaining

    # initialize the maximum pressure release found so far to the current pressure release
    max_pressure_released = pressure_released
    # initialize the path taken to reach the maximum pressure release to the current path
    max_pressure_released_path = deepcopy(path)

    # iterate over the neighbors of the current node
    for neighbour in node.connected_valves
        # if the neighbor has not been visited yet, recursively search from that node
        if !valves[neighbour].open
            # println(neighbour)
            valves[neighbour].open = true
            # add the current node to the path
            push!(path, node.name)
             # subtract the time required to move to the neighbor and open the valve from the remaining time
            pressure_released_at_neighbour, path_at_neighbour = dfs!(valves, valves[neighbour], time_remaining - 2, pressure_released, path)
            # mark the neighbor as not visited so that it can be visited again in the future
            valves[neighbour].open = false

            # update the maximum pressure release found so far and the corresponding path if necessary
            if pressure_released_at_neighbour > max_pressure_released
                max_pressure_released = pressure_released_at_neighbour
                max_pressure_released_path = path_at_neighbour
            end

            # remove the current node from the path
            pop!(path)
        end
    end

    return max_pressure_released, max_pressure_released_path
end


calc_pressure_released(valves::Valves, time_limit::Int) =
    sum(v.flow_rate * (time_limit - v.opened_at) for (_, v) in valves)

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


    # start the search at valve AA with 30 minutes of time remaining
    path = Stack{String}()
    max_pressure_released, path = dfs!(valves, last(first(valves)), 30, 1, path)
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
