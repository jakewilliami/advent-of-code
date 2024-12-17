using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

mutable struct Reg
    A::Int
    B::Int
    C::Int
end

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = get_integers.(L)
    @assert length(L) == 5
    A = only(L[1])
    B = only(L[2])
    C = only(L[3])
    @assert isempty(L[4])
    P = L[5]
    @assert all(x -> 0 ≤ x ≤ 7, P)
    return Reg(A, B, C), P
    return L
end

function combo_operand(operand::Int, R::Reg)
    operand == 7 && error("not allowed")
    0 ≤ operand ≤ 3 && return operand
    operand == 4 && return R.A
    operand == 5 && return R.B
    operand == 6 && return R.C
    error("unreachable")
end

# The adv instruction (opcode 0) performs division. The numerator is the value in the A register. The denominator is found by raising 2 to the power of the instruction's combo operand. (So, an operand of 2 would divide A by 4 (2^2); an operand of 5 would divide A by 2^B.) The result of the division operation is truncated to an integer and then written to the A register.
function adv!(ptr::Int, R::Reg, operand::Int, _io::IOBuffer)
    # println("div and store in A")
    co = combo_operand(operand, R)
    r = R.A ÷ 2^co
    R.A = r
    return ptr + 2
end

# The bxl instruction (opcode 1) calculates the bitwise XOR of register B and the instruction's literal operand, then stores the result in register B.
function bxl!(ptr::Int, R::Reg, operand::Int, _io::IOBuffer)
    # println("xor and store in B")
    r = R.B ⊻ operand
    R.B = r
    return ptr + 2
end

# The bst instruction (opcode 2) calculates the value of its combo operand modulo 8 (thereby keeping only its lowest 3 bits), then writes that value to the B register.
function bst!(ptr::Int, R::Reg, operand::Int, _io::IOBuffer)
    # println("mod and store in B")
    # println("operand=$operand")
    co = combo_operand(operand, R)
    # println("mod($co, 8) => $(mod(co, 8))")
    r = mod(co, 8)
    # println("res: $r")
    R.B = r
    return ptr + 2
end

# The jnz instruction (opcode 3) does nothing if the A register is 0. However, if the A register is not zero, it jumps by setting the instruction pointer to the value of its literal operand; if this instruction jumps, the instruction pointer is not increased by 2 after this instruction.
function jnz(ptr::Int, R::Reg, operand::Int, _io::IOBuffer)
    # println("jmp")
    iszero(R.A) && return ptr + 2
    return operand
end

# The bxc instruction (opcode 4) calculates the bitwise XOR of register B and register C, then stores the result in register B. (For legacy reasons, this instruction reads an operand but ignores it.)
function bxc!(ptr::Int, R::Reg, _operand::Int, io::IOBuffer)
    # println("xor w/ C and store in B")
    r = R.B ⊻ R.C
    R.B = r
    return ptr + 2
end

# The out instruction (opcode 5) calculates the value of its combo operand modulo 8, then outputs that value. (If a program outputs multiple values, they are separated by commas.)
function out!(ptr::Int, R::Reg, operand::Int, io::IOBuffer)
    # operand
    # println("out")
    co = combo_operand(operand, R)
    r = mod(co, 8)
    print(io, r, ",")
    return ptr + 2
end

# The bdv instruction (opcode 6) works exactly like the adv instruction except that the result is stored in the B register. (The numerator is still read from the A register.)
function bdv!(ptr::Int, R::Reg, operand::Int, _io::IOBuffer)
    # println("div and store in B")
    co = combo_operand(operand, R)
    r = R.A ÷ 2^op
    R.B = r
    return ptr + 2
end

# The cdv instruction (opcode 7) works exactly like the adv instruction except that the result is stored in the C register. (The numerator is still read from the A register.)
function cdv!(ptr::Int, R::Reg, operand::Int, _io::IOBuffer)
    # println("div and store in C")
    co = combo_operand(operand, R)
    r = R.A ÷ 2^co
    R.C = r
    return ptr + 2
end

function getop(op::Int)
    if op == 0
        return adv!
    elseif op == 1
        return bxl!
    elseif op == 2
        return bst!
    elseif op == 3
        return jnz
    elseif op == 4
        return bxc!
    elseif op == 5
        return out!
    elseif op == 6
        return bdv!
    elseif op == 7
        return cdv!
    else
        error("unreachable")
    end
end

function run!(R::Reg, P, io)
    ptr = 0
    while ptr < length(P)
        # println(ptr)
        pi = ptr + 1
        op = getop(P[pi])
        # println(op)
        ptr = op(ptr, R, P[pi + 1], io)
    end
    s = String(take!(io))
    return s[1:end-1]
end

function run!(R::Reg, P)
    run!(R, P, IOBuffer())
end

function part1(R, P)
    # R, P
    # R = Reg(0, 2024, 43690)
    # P = [4,0]
    println(join(P, ','))
    R.A = 265601188299675
    res = run!(R, P)
    res
end

function Base.copyto!(R1::Reg, R2::Reg)
    R1.A = R2.A
    R1.B = R2.B
    R1.C = R2.C
    return R2
end

function part2bruteforce(R, P)
    R′ = deepcopy(R)
    expected = join(P, ',')
    io = IOBuffer()

    a = 69995476287488
    while true
        copyto!(R, R′)
        R.A = a
        res = run!(R, P, io)
        # println("$a: $res")
        if res == expected
            return a
        end
        a += 1
    end
end

# part2 = part2bruteforce
# part2 = part1

function part2bruteforceish(R, P)
    if false
        println("==================")
        println(join(P, ','))
        R = Reg(69995476287488, 0, 0)
        println(run!(R, P))
        println("==================")
        return 0
    end

    R′ = deepcopy(R)
    A′ = R.A
    expected = join(P, ',')
    io = IOBuffer()
    res = run!(R, P, io)
    while length(res) < length(expected)
        copyto!(R, R′)
        A′ *= 2
        R.A  = A′
        res = run!(R, P, io)
    end
    println("==================")
    println(A′)
    println(expected)
    println(res)
    println("==================")
    0
end

# part2 = part2bruteforceish

# function part2backwards(R, P)
# end

# part2 = part2backwards
#
# Quite stuck on this one... not entirely sure why this works but I adapted from the following
# https://www.reddit.com/r/adventofcode/comments/1hg38ah/comment/m2glx6y/
#
# It seemed like one of the solutions that used the least amount of manual decompiling of the program
function solve_recursive(R, P, target, io, a=0, depth=0)
    if depth == length(target)
        return a
    end
    for i in 0:7
        R′ = deepcopy(R)
        R′.A = 8a + i
        output = run!(R′, P, io)
        if !isempty(output) && parse(Int, first(output)) == target[depth + 1]
            result = solve_recursive(R′, P, target, io, 8a + i, depth + 1)
            if result != 0
                return result
            end
        end
    end
    return 0
end

function part2recursive(R, P)
    target = reverse(P)
    io = IOBuffer()
    solve_recursive(deepcopy(R), P, target, io)
end

part2 = part2recursive

function main()
    R, P = parse_input("data17.txt")
    # R, P = parse_input("data17.test.txt")
    # R, P = parse_input("data17.test2.txt")

    # Part 1
    part1_solution = part1(deepcopy(R), P)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(deepcopy(R), P)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
