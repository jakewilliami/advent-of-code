# TODO
# day 11 monkeys last year, day 6 fishes from 2021

using Base.Iterators

function parse_input(input_file::String)
    L = readlines(input_file)
    D = Dict{String, Tuple{String, String}}()
    A, rest = Iterators.peel(L)
    for line in rest
        isempty(strip(line)) && continue
        k, v = split(line, " = ")
        D[String(k)] = Tuple(String.(split(v[2:end-1], ", ")))
    end
    return A, D
end

function follow_instruction(instruction::Char, vals::Tuple{String, String})
    instruction == 'L' && return first(vals)
    instruction == 'R' && return last(vals)
    error("Unhandled instruction $instruction")
end

function solve_steps(start_node::String, instructions::String, map::Dict{String, Tuple{String, String}}, is_ending_node::Function)
    node = start_node
    i = 0
    i, steps = 1, 0
    while !is_ending_node(node)
        instruction = instructions[i]
        node = follow_instruction(instruction, map[node])
        i += 1; steps += 1
        if i > length(instructions)
            i = 1
        end
    end
    return steps
end

function part1(data)
    instructions, map = data
    is_ending_node(node::String) = node == "ZZZ"
    i, steps = 1, 0
    return solve_steps("AAA", instructions, map, is_ending_node)
end

function part2_naive(data)
    instructions, map = data
    is_starting_node(node::String) = endswith(node, 'A')
    is_ending_node(node::String) = endswith(node, 'Z')

    starting_nodes = String[k for k in keys(map) if is_starting_node(k)]

    nodes = copy(starting_nodes)
    i, steps = 1, 0
    while !all(is_ending_node(n) for n in nodes)
        instruction = instructions[i]
        nodes = [follow_instruction(instruction, map[n]) for n in nodes]
        i += 1; steps += 1
        if i > length(instructions)
            i = 1
        end
    end
    return steps
end

function part2(data)
    instructions, map = data
    is_starting_node(node::String) = endswith(node, 'A')
    is_ending_node(node::String) = endswith(node, 'Z')

    # 18df7px comment kcgrqgs
    starting_nodes = String[n for n in keys(map) if is_starting_node(n)]
    return lcm((solve_steps(n, instructions, map, is_ending_node) for n in starting_nodes)...)
end

function main()
    data = parse_input("data08.txt")
    # data = parse_input("data08.test.txt")

    # Part 1
    # part1_solution = part1(data)
    # @assert part1_solution == 12643
    # println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
