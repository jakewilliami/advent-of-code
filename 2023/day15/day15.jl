# We are given a long list of strings separated by commas.  The elves give
# us a "hashing algorithm" that we have to run on each string and add them
# together in part 1.
#
# Part 2 was Advent of Reading Comprehension.  I had to do this later at
# night because I had something on, but even still I struggled understanding
# what turned out to be a simple problem!  The input are actually keys with
# instructions and we have to place them in a certain way into boxes, and
# calculate a score at the end of the process.  Similar to part 1, it was
# very basic, but took a little bit of thinking because English is hard.

using OrderedCollections

function parse_input(input_file::String)
    S = strip(read(input_file, String))
    return String.(split(S, ','))
end


### Part 1 ###

function elf_hash(s::AbstractString)
    ans = 0
    for c in s
        ans = rem((ans + Int(c)) * 17, 256)
    end
    return ans
end

part1(data::Vector{String}) = sum(elf_hash(s) for s in data)


### Part 2 ###

@enum Operation set decrement

struct Instruction
    op::Operation
    key::String
    value::Int
end

function parse_instruction(s::String)
    if '=' in s
        n, v = split(s, '=')
        return Instruction(set, n, parse(Int, v))
    else
        @assert endswith(s, '-')
        return Instruction(decrement, s[1:(end - 1)], 0)
    end
end

function calculate_focussing_power(boxes::Vector{OrderedDict{String, Int}})
    res = 0
    for (i, box) in enumerate(boxes)
        for (j, (lens, len)) in enumerate(box)
            res += prod((i, j, len))
        end
    end
    return res
end

function part2(data::Vector{String})
    boxes = OrderedDict{String, Int}[OrderedDict{String, Int}() for _ in 1:256]

    for s in data
        instruction = parse_instruction(s)
        box_i = elf_hash(instruction.key) + 1

        if instruction.op == set
            boxes[box_i][instruction.key] = instruction.value
        elseif instruction.op == decrement
            pop!(boxes[box_i], instruction.key, nothing)
        else
            error("Unhandled operation type $(repr(instruction.op))")
        end
    end

    return calculate_focussing_power(boxes)
end

function main()
    data = parse_input("data15.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 515974
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 265894
    println("Part 2: $part2_solution")
end

main()
