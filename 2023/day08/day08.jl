# day 11 monkeys last year, day 6 fishes from 2021
# 2 kinds of hard: memory and counting/iterations, fishes is memory hard, counting is maths hard

using Base.Iterators

### Parse Input ###

struct InstructionFork
    left::String
    right::String
end

struct InstructionMap
    instructions::String
    map::Dict{String, InstructionFork}
end

Base.keys(m::InstructionMap) = keys(m.map)

function parse_input(input_file::String)
    L = readlines(input_file)
    D = Dict{String, InstructionFork}()
    A, rest = Iterators.peel(L)
    for line in rest
        isempty(strip(line)) && continue
        k, v = split(line, " = ")
        D[String(k)] = InstructionFork(String.(split(v[2:end-1], ", "))...)
    end
    return InstructionMap(A, D)
end

### Part 1 ###

function follow_instruction(instruction::Char, fork::InstructionFork)
    instruction == 'L' && return fork.left
    instruction == 'R' && return fork.right
    error("Unhandled instruction $instruction")
end

function solve_steps(start_node::String, map::InstructionMap, is_ending_node::Function)
    node = start_node
    i, steps = 1, 0
    while !is_ending_node(node)
        instruction = map.instructions[i]
        node = follow_instruction(instruction, map.map[node])
        i += 1; steps += 1
        if i > length(map.instructions)
            i = 1
        end
    end
    return steps
end

function part1(data::InstructionMap)
    is_ending_node(node::String) = node == "ZZZ"
    i, steps = 1, 0
    return solve_steps("AAA", data, is_ending_node)
end

### Part 2 ###

function part2(data::InstructionMap)
    is_starting_node(node::String) = endswith(node, 'A')
    is_ending_node(node::String) = endswith(node, 'Z')

    # 18df7px comment kcgrqgs
    return lcm((solve_steps(n, data, is_ending_node) for n in keys(data) if is_starting_node(n))...)
end

function main()
    data = parse_input("data08.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 12643
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 13133452426987
    println("Part 2: $part2_solution")
end

main()
