# Today was interesting.  We were given three registers' initial states, and a
# program, which is a series of numbers.  Based on some specified operations,
# we were to simulate the given program, which can modify the registry's state
# and output numbers.
#
# In part 1, we simply needed to simulate the machine as per the instructions
# on how the machine works, which was provided in the problem statement.  This
# was fine; literally no trick here.
#
# Part 2, however...we were asked to find an initial value for A such that the
# program's output is the same as the input program.  A quine, as it were!
# There is some logic related to the way the program is parsed which means we
# can effectively work backwards to find the answer.  I don't fully understand
# it so my solution to this part is not entirely my own, but adapted from the
# following:
# <https://www.reddit.com/r/adventofcode/comments/1hg38ah/comment/m2glx6y/>
#
# A lot of today's part 2 solutions seemed to be not generic for all inputs,
# but a result of specific program inputs.  I'm keen to better understand
# why this solution works, and if there is a generalised solution for this
# problem.  (I don't think you can simply work backwards because the operations
# are not all one-to-one invertible.)

using AdventOfCode.Parsing


### Parse Input ###

mutable struct Registry
    A::Int
    B::Int
    C::Int
end

mutable struct State
    reg::Registry
    ptr::Int
    out::Vector{Int8}
end

State(reg::Registry) = State(reg, 0, Int[])

mutable struct Machine
    state::State
    program::Vector{Int8}
end

function parse_input(input_file::String)
    L = strip.(readlines(input_file))
    L = get_integers.(L)
    @assert length(L) == 5
    A = only(L[1])
    B = only(L[2])
    C = only(L[3])
    @assert isempty(L[4])
    P = L[5]
    @assert all(x -> 0 ≤ x ≤ 7, P)
    return Machine(State(Registry(A, B, C)), Int8.(P))
end


### Part 1 ###

function combo_operand(machine::Machine, operand::Int8)
    operand == 7 && error("operand not allowed")
    0 ≤ operand ≤ 3 && return operand
    operand == 4 && return machine.state.reg.A
    operand == 5 && return machine.state.reg.B
    operand == 6 && return machine.state.reg.C
    error("unreachable")
end

function adv!(machine::Machine, operand::Int8)
    co = combo_operand(machine, operand)
    machine.state.reg.A = machine.state.reg.A ÷ 2^co
    machine.state.ptr += 2
    return machine
end

function bxl!(machine::Machine, operand::Int8)
    machine.state.reg.B = machine.state.reg.B ⊻ operand
    machine.state.ptr += 2
    return machine
end

function bst!(machine::Machine, operand::Int8)
    co = combo_operand(machine, operand)
    machine.state.reg.B = mod(co, 8)
    machine.state.ptr += 2
    return machine
end

function jnz!(machine::Machine, operand::Int8)
    if iszero(machine.state.reg.A)
        machine.state.ptr += 2
        return machine
    end
    machine.state.ptr = operand
    return machine
end

function bxc!(machine::Machine, _operand::Int8)
    machine.state.reg.B = machine.state.reg.B ⊻ machine.state.reg.C
    machine.state.ptr += 2
    return machine
end

function out!(machine::Machine, operand::Int8)
    co = combo_operand(machine, operand)
    push!(machine.state.out, mod(co, 8))
    machine.state.ptr += 2
    return machine
end

function bdv!(machine::Machine, operand::Int8)
    co = combo_operand(machine, operand)
    machine.state.reg.B = machine.state.reg.A ÷ 2^op
    machine.state.ptr += 2
    return machine
end

function cdv!(machine::Machine, operand::Int8)
    co = combo_operand(machine, operand)
    machine.state.reg.C = machine.state.reg.A ÷ 2^co
    machine.state.ptr += 2
    return machine
end

function getop(op::Int8)
    op == 0 && return adv!
    op == 1 && return return bxl!
    op == 2 && return bst!
    op == 3 && return jnz!
    op == 4 && return bxc!
    op == 5 && return out!
    op == 6 && return bdv!
    op == 7 && return cdv!
    error("unreachable")
end

function run!(machine::Machine)
    while machine.state.ptr < length(machine.program)
        pi = machine.state.ptr + 1
        op! = getop(machine.program[pi])
        op!(machine, machine.program[pi + 1])
    end
end

function part1(machine::Machine)
    run!(machine)
    return join(machine.state.out, ',')
end


### Part 2 ###

function Base.copyto!(R1::Registry, R2::Registry)
    R1.A = R2.A
    R1.B = R2.B
    R1.C = R2.C
    return R2
end

# Quite stuck on this one... not entirely sure why this works but I adapted
# from the following:
# <https://www.reddit.com/r/adventofcode/comments/1hg38ah/comment/m2glx6y/>
#
# It seemed like one of the solutions that used the least amount of manual
# decompiling of the program
function solve_recursive(machine::Machine, target::Vector{Int8}, a::Int = 0, depth::Int = 0)
    depth == length(target) && return a

    for i in 0:7
        # Construct new machine with initial state and modified registry
        machine = Machine(State(deepcopy(machine.state.reg)), machine.program)
        machine.state.reg.A = 8a + i
        run!(machine)
        isempty(machine.state.out) && continue
        if first(machine.state.out) == target[depth + 1]
            result = solve_recursive(machine, target, 8a + i, depth + 1)
            iszero(result) || return result
        end
    end

    return 0
end

function part2(machine::Machine)
    target = reverse(machine.program)
    a = solve_recursive(deepcopy(machine), target)

    # Sanity-check results
    machine.state.reg.A = a
    run!(machine)
    @assert machine.state.out == machine.program

    # Return value for register A
    return a
end


### Main ###

function main()
    machine = parse_input("data17.txt")

    # Part 1
    part1_solution = part1(deepcopy(machine))
    @assert part1_solution == "2,0,4,2,7,0,1,0,3"
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(deepcopy(machine))
    @assert part2_solution == 265601188299675
    println("Part 2: $part2_solution")
end

main()
