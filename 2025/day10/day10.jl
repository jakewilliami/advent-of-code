# slow on part 1 - tired and slightly convoluted

# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

# ]add https://github.com/jakewilliami/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools  # TODO: IterTools, ProgressMeter, BenchmarkTools, Memoization
# ]add IterTools ProgressMeter BenchmarkTools Memoization
# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools
using JuMP, GLPK


### Parse Input ###

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    function parse_one(s)
        parts = split(s)

        # Lights
        lights_s = parts[1]
        lights_s = strip(strip(lights_s, '['), ']')
        lights = falses(length(lights_s))
        lights[findall(==('#'), lights_s)] .= true

        # Buttons
        buttons_s = parts[2:end-1]
        function parse_button(x)
            x = strip(strip(x, '('), ')')
            return parse.(Int, split(x, ',')) .+ 1 # for 1-based indexing
        end
        # buttons = [parse_button(b) for b in split(buttons_s)]
        buttons = parse_button.(buttons_s)

        # Joltage requirements
        joltage_s = parts[end]
        joltage_s = strip(strip(joltage_s, '{'), '}')
        joltage = parse.(Int, split(joltage_s, ','))

        return lights, buttons, joltage
    end
    L = [parse_one(l) for l in L]
    return L
    # L = get_integers.(L)
    return L
end


### Part 1 ###

# TODO: represent as bitmask
function apply_button!(lighting::BitVector, button_wiring::Vector{Int})
    lighting[button_wiring] .⊻= true
    return lighting
end

function apply_buttons!(lighting::BitVector, button_wirings::Vector{Vector{Int}})
    for button_wiring in button_wirings
        apply_button!(lighting, button_wiring)
    end
    return lighting
end

# function to_mask(v::BitVector)
#     mask = zero(UInt64)
#     for (i, b) in enumerate(v)
#         mask |= UInt64(b) << (i - 1)
#     end
#     mask
# end

function find_solution(schematic, buttons)
    # schematic is the target; lighting is the one we apply button presses to
    # lighting = similar(schematic)
    start = falses(length(schematic))

    # short circuit if already same
    start == schematic && return Int[]

    # data structures for bfs
    Q = Queue{Tuple{BitVector, Vector{Int}}}()
    seen = Set{BitVector}()
    push!(Q, (start, Int[]))
    push!(seen, start)

    while !isempty(Q)
        lighting, path = popfirst!(Q)

        for (i, button) in enumerate(buttons)
            newstate = copy(lighting)
            apply_button!(newstate, button)

            newstate ∈ seen && continue
            push!(seen, newstate)

            newpath = [path...; i]  # vcat?
            # println("$newstate $schematic $newpath $(buttons[newpath])")
            # answer = apply_buttons!(falses(length(schematic)), buttons[newpath])
            newstate == schematic && return newpath
            # answer == schematic && return newpath

            push!(Q, (newstate, newpath))
        end
    end
end

function part1(data)
    data = deepcopy(data)
    # one = data[3]
    # println()
    # map(println, data)
    # schematic, buttons, _ = one
    # println(buttons)
    # println()
    # solution = find_solution(schematic, buttons)
    # solution = buttons[solution]
    # [button_press .- 1 for button_press in solution]

    sum(data) do (schematic, buttons, _)
        length(find_solution(schematic, buttons))
    end
end


### Part 2 ###

function apply_button_2!(counter::Vector{Int}, button_wiring)
    counter[button_wiring] .+= 1
    return counter
end

function find_solution_21(target::Vector{Int}, buttons)
    start = zeros(Int, length(target))

    start == target && return Int[]

    visited = Set{Vector{Int}}()
    queue = [(start, Int[])]
    push!(visited, copy(start))

    while !isempty(queue)
        counter, path = popfirst!(queue)

        for (i, button) in enumerate(buttons)
            newstate = copy(counter)
            apply_button_2!(newstate, button)

            # Prune states that exceed the target (optional, but huge speedup)
            if any(newstate .> target)
                continue
            end

            if newstate ∈ visited
                continue
            end

            push!(visited, copy(newstate))
            newpath = [path...; i]

            if newstate == target
                return newpath
            end

            push!(queue, (newstate, newpath))
        end
    end

    return nothing
end


function find_solution_2(target::Vector{Int}, buttons)
    start = zeros(Int, length(target))

    start == target && return 0

    visited = Set{Vector{Int}}()
    queue = [(start, 0)]
    push!(visited, copy(start))

    while !isempty(queue)
        counter, n = popfirst!(queue)

        for (i, button) in enumerate(buttons)
            newstate = copy(counter)
            apply_button_2!(newstate, button)

            # Prune states that exceed the target (optional, but huge speedup)
            if any(newstate .> target)
                continue
            end

            if newstate ∈ visited
                continue
            end

            push!(visited, copy(newstate))
            # n += 1

            if newstate == target
                return n + 1
            end

            push!(queue, (newstate, n + 1))
        end
    end

    return nothing
end

#=
  const Z3 = context(`problem_${index}`);

  const optimizer = new Z3.Optimize();

  const buttonVars: Arith<`problem_${number}`>[] = [];
  for (let i = 0; i < data.buttons.length; i++) {
    const button = Z3.Int.const(`button_${i}`);
    buttonVars.push(button);
    optimizer.add(button.ge(0));
  }

  for (let i = 0; i < data.counters.length; i++) {
    const target = data.counters[i];
    const buttons: Arith<`problem_${number}`>[] = [];
    for (let j = 0; j < data.buttons.length; j++) {
      if (data.buttons[j].includes(i)) {
        buttons.push(buttonVars[j]);
      }
    }
    if (buttons.length > 0) {
      const sum = buttons.reduce((acc, val) => acc.add(val));
      optimizer.add(sum.eq(target));
    }
  }

  assert(buttonVars.length > 0);
  const total = buttonVars.reduce((acc, val) => acc.add(val));

  optimizer.minimize(total);

  const sat = await optimizer.check();
=#

# adapted from:
# https://github.com/jakewilliami/advent-of-code/blob/af2ca6b0/2024/day13/day13.jl#L71-L94
# function solve(machine::Machine)
function solve(target::Vector{Int}, buttons)
    m = Model(GLPK.Optimizer)



    B = length(buttons)
    n = length(target)

    @variable(m, x[1:B] >= 0, Int)

    # Sum of button effects equals the target
    @constraint(m, [i in 1:n],
        sum(x[b] * (i in buttons[b] ? 1 : 0) for b in 1:B) == target[i]
    )

    # Minimise total number of presses
    @objective(m, Min, sum(x[b] for b in 1:B))

    optimize!(m)

    termination_status(m) == MOI.OPTIMAL || return nothing

    return round.(Int, value.(x))



    # Number of button presses a and b
    @variable(m, a >= 0, Int)
    @variable(m, b >= 0, Int)

    # Button presses must add to target in order to win prize
    # Can't use cartesian indices directly so have to check each dimension separately
    @constraint(m, [i=1:2], a * machine.a.I[i] + b * machine.b.I[i] == machine.prize.I[i])

    # Minimize number of button presses
    @objective(m, Min, 3a + b)
    optimize!(m)

    # If no optimal solution is found, return zeros
    # In real life, you wouldn't want to return valid numbers as it implies
    # a solution was found, but for this situation it is good enough
    termination_status(m) == MOI.OPTIMAL || return 0, 0

    # Otherwise, we found a solution
    return round.(Int, (value(a), value(b)))
end

function part2(data)
    data = deepcopy(data)
    one = data[1]
    # println()
    # map(println, data)
    _, buttons, target = one
    # return solve(target, buttons)

    # return
    # println(buttons)
    # println()
    # solution = find_solution_2(target, buttons)
    # solution = buttons[solution]
    # [button_press .- 1 for button_press in solution]

    # too many fishes????

    # for (_, buttons, target) in data
    #     println(length(find_solution_21(target, buttons)))
    # end
    # println()

    sum(enumerate(data)) do (i, (_, buttons, target))
        println("$i/$(length(data))")
        # length(find_solution_2(target, buttons))
        # s = find_solution_2(target, buttons)
        s = solve(target, buttons)
        # println(s)
        # s
        sum(s)
    end
end


### Main ###

function main()
    data = parse_input("data10.txt")
    # data = parse_input("data10.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 547
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
