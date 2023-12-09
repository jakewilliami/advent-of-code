# The data for this consisted of instructions on the first line, and a map of
# nodes on the following lines.  What we had to do was to start at a certain
# node and follow either the left or right node until we reach the end.  For
# example:
#   Instruction: L, Node: AAA = (BBB, CCC)
#   We are on node A and must take the left (L) path to node BBB.
#
# Part 1 of the problem got us to start at node AAA and follow the map until
# we reached node ZZZ.  This was straight forward.
#
# Part 2 is classic Advent of Code, reminding me of day 11 (monkeys) from last
# year/day 13 (buses) from 2020, and a little of day 6 (too many fishes) from 2021.
# We had to start simultaneously at *all* nodes ending with A, and go until they
# all simultaneously meet nodes that end with Z.  This answer clearly uses the LCM,
# or there may even be a CRT solution.  I hope I will gain that from these kinds of
# problems.  I understand the solution for this question, but needed a nudge in the
# right direction.  Hoping in the future I will have an intuition about these kinds
# of solutions without any help.


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
        steps += 1
        i = mod1(i + 1, length(map.instructions))
    end
    return steps
end

function part1(data::InstructionMap)
    is_ending_node(node::String) = node == "ZZZ"
    return solve_steps("AAA", data, is_ending_node)
end


### Part 2 ###

function part2(data::InstructionMap)
    is_starting_node(node::String) = endswith(node, 'A')
    is_ending_node(node::String) = endswith(node, 'Z')

    # Each starting node has a path of length n until it reaches an ending node.
    # To get a solution where *all* ghosts have found their ending node simultaneously,
    # we simply take the least common multiplier from each path, rather than
    # modelling this ourselves.  18df7px comment kcgrqgs
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
