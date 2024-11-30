using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

MAIN_PRINT = false
# MAIN_PRINT = true

function flip_flops(data)
    D = Dict()
    for (a, b) in data
        if first(a) == '%'
            D[a[2:end]] = (false, b)
        end
    end
    return D
end

function flip_flops_reverse(data)
    # D = DefaultDict(String[])
    D = Dict()
    for (a, b) in data
        if first(a) == '%'
            for b1 in b
                k = a[2:end]
                # TODO: instead of k in keys(D) use haskey(D, k)
                if !(b1 in keys(D))
                    D[b1] = String[]
                end
                if !(k in D[b1])
                    push!(D[b1], k)
                end
            end
        end
    end
    return D
end

function get_inputs(data)
    # D = DefaultDict(String[])
    D = Dict()
    for (a, b) in data
        a == "broadcaster" && continue
        k = a[2:end]
        for b1 in b
            # TODO: instead of k in keys(D) use haskey(D, k)
            if !(b1 in keys(D))
                D[b1] = String[]
            end
            if !(k in D[b1])
                # println("Adding $k to inputs for $b1")
                push!(D[b1], k)
            end
        end
    end
    return D
end

function conjuncts(data::AbstractVector)
    # FR = flip_flops_reverse(data)
    FR = get_inputs(data)
    D = Dict()
    for (a, b) in data
        if first(a) == '&'
            k = a[2:end]
            D[k] = (Dict(inp => 0 for inp in FR[k]), b)#Dict(b1 => 0 for b1 in b)
        end
    end
    return D
end

function parse_input1(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = [String.(split(l, " -> ")) for l in L]
    L = [(a, String.(split(b, ", "))) for (a, b) in L]
    F, FR, C = flip_flops(L), flip_flops_reverse(L), conjuncts(L)
    F, FR, C = flip_flops(L), get_inputs(L), conjuncts(L)
    D = Dict(a => b for (a, b) in L)
    return D, F, FR, C
    # L = [(a[1], a[2:end], b) for (a, b) in L]
    # L = get_integers.(L)
    return L
end

# rewrite parsing and data-structures because my solution is too buggy and I can't debug it
function parse_input(input_file::String)
    L = []
    FF, I, C = Dict(), Dict(), Dict()
    for line in eachline(input_file)
        line = strip(line)
        a, b = String.(split(line, " -> "))
        b = String.(split(b, ", "))
        push!(L, (a, b))


        # Flip-flip
        if first(a) == '%'
            k = a[2:end]
            FF[k] = Dict("active" => false, "outputs" => b)
        end

        # Inputs
        if a != "broadcaster"
            k = a[2:end]
            for b1 in b
                if !haskey(I, b1)
                    I[b1] = Dict("inputs" => String[])
                end
                if !(k in I[b1]["inputs"])
                    push!(I[b1]["inputs"], k)
                end
            end
        end
    end

    # Conjucts
    for (a, b) in L
        if first(a) == '&'
            k = a[2:end]
            m = Dict(input => 0 for input in I[k]["inputs"])
            C[k] = Dict("memory" => m, "outputs" => b)
        end
    end

    D = Dict(a => b for (a, b) in L)
    return D, FF, I, C
end

# % flip flop
# & conjunction

function dis_sig(i, src, dst, l)
    si = i == 0 ? "low" : "high"
    si == "high" && @assert i == 1
    pref = "++ [L$l]"
    pref = "$(basename(@__FILE__)):$l:"
    # println("++Sending $si signal from $(repr(src)) to $(repr(dst))")
    MAIN_PRINT && println("$pref $src -$si-> $dst")
end
dis_sig(i, src, dst) = dis_sig(i, src, dst, "?")

# NOTE: do not use this function; misunderstood the problem
function update_rev_ff1!(i, src, k, F, FR, C)
    MAIN_PRINT && println("<-> $(F[k])")
    for k2 in last(F[k])
        k2 in keys(C) || continue
        d, x = C[k2]
        d[k] = i# == 0 ? 1 : 0
        C[k2] = (d, x)
    end
    return C
end

# Flip-flop modules (prefix %) are either on or off; they are initially off. If a flip-flop module receives a high pulse, it is ignored and nothing happens. However, if a flip-flop module receives a low pulse, it flips between on and off. If it was off, it turns on and sends a high pulse. If it was on, it turns off and sends a low pulse.
function handle_ff1!(i, src, k, F, FR, C)
    dis_sig(i, src, k, @__LINE__)
    i == 1 && return nothing
    @assert i == 0
    b, v = F[k]
    F[k] = (!b, v)
    s = b ? 0 : 1
    # update for C to remember
    update_rev_ff!(s, src, k, F, FR, C)
    return s
    # if !b
        # return 1
    # else
        # return 0
    # end
end

# Conjunction modules (prefix &) remember the type of the most recent pulse received from each of their connected input modules; they initially default to remembering a low pulse for each input. When a pulse is received, the conjunction module first updates its memory for that input. Then, if it remembers high pulses for all inputs, it sends a low pulse; otherwise, it sends a high pulse.
function handle_c1!(i, src, k, F, FR, C)
    dis_sig(i, src, k, @__LINE__)
    # _i = handle_ff!(i, src, k, F, FR, C)
    # C[k] =
    # TODO: update memory first?
    # println("    $()")
    MAIN_PRINT && println("    ==$(C[k]) $((all(v == 1 for v in values(first(C[k])))))")
    if all(v == 1 for v in values(first(C[k])))
    # if all(v == 1 for v in first(values(FR[k])))
    # if all(v == 1 for v in values(C[k]))
        return 0
    else
        return 1
    end
end

#=
button -low-> broadcaster
broadcaster -low-> a
a -high-> inv
a -high-> con
inv -low-> b
con -high-> output
b -high-> con
con -low-> output
=#

DataStructures.enqueue!(S::Stack, x) = push!(S, x)
DataStructures.dequeue!(S::Stack) = pop!(S)

function pulse1!(si, sk, D, F, FR, C, pulses)
    # increment button push
    inc!(pulses, si)
    dis_sig(si, "button", sk, @__LINE__)
    # fn = identity
    # fn = reverse
    # i = 0: low; i = 1: high
    # TODO: do i need to use a stack?
    Q = Queue{Any}()
    out = DefaultDict([])
    # Q = Stack{Any}()
    fn = Q isa Stack ? reverse : identity
    # pk = sk
    # println("$sk -> $(D[sk])")
    for k in D[sk]
        dis_sig(si, sk, k, @__LINE__)
        enqueue!(Q, (si, sk, k))
        # pulses += 1
        # increment each broadcast initial
        # inc!(pulses, si)
    end
    # println(Q)
    while !isempty(Q)
        i, pk, k = dequeue!(Q)
        MAIN_PRINT && println("    $i $pk $k [$F]")
        i === nothing && continue
        # inc!(pulses, i)
        # A = D[k]
        # a = k == sk ? k : k in keys(F) ? "%$k" : "&$k"
        a = k
        MAIN_PRINT && println("[", i, " ", a, "]")
        if a in keys(F)
            # println("found $a in $(keys(F))")
            # pulses += 1
            inc!(pulses, i)
            i2 = handle_ff!(i, pk, a, F, FR, C)
            # i2 === nothing || inc!(pulses, i2)
            # for v in D["%$a"]
            MAIN_PRINT && println("[ff] $a -> $(F[a]) ($Q)")
            for v in fn(last(F[a]))
                # println("   $v")
                enqueue!(Q, (i2, a, v))
            end
        elseif a in keys(C)
            inc!(pulses, i)
            i2 = handle_c!(i, pk, a, F, FR, C)
            # i2 === nothing || inc!(pulses, i2)
            MAIN_PRINT && println("[conj] $a -> $(C[a]) <- $(FR[a]) ($Q)")
            for v in fn(last(C[a]))
                enqueue!(Q, (i2, a, v))
            end
        else
            # println("WARN: Unknown key $(repr(a))")
            MAIN_PRINT && print("[output] ")
            dis_sig(i, pk, a, @__LINE__)
            # push!(out[a], i)
            # pulses += 1
            # inc!(pulses, i)
            # TODO: why is this always 0?  TODO: it's not; I must be resetting it incorrectly!
            inc!(pulses, i)
            # println("!!!!!!", pulses)
        end
    end
    return pulses
end

function update_memories_from_ff!(i, src, dst, F, I, C)
    # If some dst flip-flip got a signal, we have to find the conjs that it connects to and update their memory
    for conn in F[dst]["outputs"]
        if haskey(C, conn)
            C[conn]["memory"][dst] = i
        end
    end

    return C
end

# Flip-flop modules (prefix %) are either on or off; they are initially off. If a flip-flop module receives a high pulse, it is ignored and nothing happens. However, if a flip-flop module receives a low pulse, it flips between on and off. If it was off, it turns on and sends a high pulse. If it was on, it turns off and sends a low pulse.
function handle_ff!(ii, src, dst, F, I, C)
    dis_sig(ii, src, dst, @__LINE__)

    # Do nothing if high signal
    ii == 1 && return nothing

    # Update flip-flip if low signal
    @assert ii == 0
    F[dst]["active"] = !F[dst]["active"]

    # Calculate output signal
    io = F[dst]["active"] ? 1 : 0

    # Update connector's memories
    # update_memories_from_ff!(io, src, dst, F, I, C)

    return io
end

function update_memory_from_c!(i, src, dst, F, I, C)
    @assert haskey(C[dst]["memory"], src)
    C[dst]["memory"][src] = i
    return C
end

# Conjunction modules (prefix &) remember the type of the most recent pulse received from each of their connected input modules; they initially default to remembering a low pulse for each input. When a pulse is received, the conjunction module first updates its memory for that input. Then, if it remembers high pulses for all inputs, it sends a low pulse; otherwise, it sends a high pulse.
function handle_c!(ii, src, dst, F, I, C)
    dis_sig(ii, src, dst, @__LINE__)

    # Update memory for that input
    update_memory_from_c!(ii, src, dst, F, I, C)

    # Get result
    # if sum(values(C[dst]["memory"])) == length(I[dst])
    if all(v == 1 for v in values(C[dst]["memory"]))
        return 0
    else
        return 1
    end
end

function pulse!(si, sk, D, F, I, C, pulses)
    # pulse from button press
    inc!(pulses, si)
    dis_sig(si, "button", sk, @__LINE__)

    # Initialise queue from broadcast signal
    Q = Queue{Any}()
    for k in D[sk]
        dis_sig(si, sk, k, @__LINE__)
        enqueue!(Q, (si, sk, k))
    end

    # Main loop
    while !isempty(Q)
        ii, pk, ck = dequeue!(Q)
        ii == nothing && continue
        inc!(pulses, ii)

        if haskey(F, ck)
            # flip-flops
            io = handle_ff!(ii, pk, ck, F, I, C)
            for nk in F[ck]["outputs"]
                enqueue!(Q, (io, ck, nk))
            end
        elseif haskey(C, ck)
            # conjunctions
            io = handle_c!(ii, pk, ck, F, I, C)
            for nk in C[ck]["outputs"]
                enqueue!(Q, (io, ck, nk))
            end
        else
            # output node
            dis_sig(ii, pk, ck, @__LINE__)
        end
    end

    return pulses
end

#=
None broadcaster 0 0
broadcaster nd 0 True
broadcaster fx 0 True
broadcaster mc 0 True
broadcaster lf 0 True
nd lg True True
fx st True True
mc gr True True
lf bn True True
lg rr True False
st zb True False
gr js True False
bn bs True False
rr hb False True
zb hb False True
js hb False True
bs hb False True
[9, 38]
=#

function part1(data)
    D, F, FR, C = deepcopy(data)
    sk, si = "broadcaster", 0
    pulses = Accumulator{Int, Int}()
    N = 1
    N *= 1000
    # N *= 2
    for _ in 1:N
        pulse!(si, sk, D, F, FR, C, pulses)
        # println(F)
    end
    println(pulses)
    # one: 342
    # [9, 38]
    return prod(values(pulses))
end

function pulse2!(si, sk, D, F, I, C, pulses)
    rxs = 0
    # Suppose there are n sub-trees and they each have their own cycle

    # pulse from button press
    inc!(pulses, si)
    dis_sig(si, "button", sk, @__LINE__)

    # Initialise queue from broadcast signal
    Q = Queue{Any}()
    for k in D[sk]
        dis_sig(si, sk, k, @__LINE__)
        enqueue!(Q, (si, sk, k))
    end

    ci = 0
    while pulses[ci] < length(sources)

        # Main loop
        while !isempty(Q)
            ii, pk, ck = dequeue!(Q)
            ii == nothing && continue
            inc!(pulses, ii)

            if ck == "rx" && ii != 1
                rxs += 1
            end

            if haskey(F, ck)
                # flip-flops
                io = handle_ff!(ii, pk, ck, F, I, C)
                for nk in F[ck]["outputs"]
                    enqueue!(Q, (io, ck, nk))
                end
            elseif haskey(C, ck)
                # conjunctions
                io = handle_c!(ii, pk, ck, F, I, C)
                for nk in C[ck]["outputs"]
                    enqueue!(Q, (io, ck, nk))
                end
            else
                # output node
                dis_sig(ii, pk, ck, @__LINE__)
            end
        end
    end

    return rxs
end

function part2(data)
    D, F, FR, C = deepcopy(data)
    sk, si = "broadcaster", 0
    pulses = Accumulator{Int, Int}()
    N = 1
    N *= 1000
    # N *= 2
    for _ in 1:N
        rxs = pulse2!(si, sk, D, F, FR, C, pulses)
    end
    println(pulses)
    return prod(values(pulses))
end

function main()
    data = parse_input("data20.txt")
    # data = parse_input("data20.test.txt")
    # data = parse_input("data20.test2.txt")
    # println(data)

    MAIN_PRINT && println("Raw: $(data[1])")
    MAIN_PRINT && println("Flipflops: $(data[2])")
    MAIN_PRINT && println("Rev-flipflops: $(data[3])")
    MAIN_PRINT && println("Conjs: $(data[4])")
    MAIN_PRINT && println()

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 684125385
    println("Part 1: $part1_solution")
    # Not 590256506 too low
    # Not 535448680

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
