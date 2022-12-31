# I found today a bit tricky!  We were given instructions: either "noop" (no operation), or
# "addx n".  We had to keep track of a register, that the "addx" instructions would modify.
#
# In part 1, we had to follow these instructions (according to the description in the
# puzzle), and state the "signal strength" after these instructions (which is obtained by
# the sum of the register value multiplied by the cycle index for 20ᵗʰ, 60ᵗʰ, 100ᵗʰ, 140ᵗʰ,
# 180ᵗʰ, and 220ᵗʰ cycles.  The tricky part came when we followed the addx instruction: it
# only modifies the register _after two cycles_.  Keeping track of the instruction count,
# the cycle count, the register value, and the answer value (which accumulated every 40
# rounds after round 20) was a bit of a headache, and I had a lot of off-by-one errors.
#
# Part 2 was also tricky.  Not only do we have to still keep track of the register value and
# the addx counter, but keep track of the position of a "sprite".  Furthermore, the result
# was read from a display; this is something that Advent of Code problems sometimes do,
# where you are asked to draw dots and hashes, and read the output, which forms letters.
# The pixels written to this display were a product of the sprite position.  Once again, I
# had more off-by-one errors than I'd care to admit in this problem.
#
# Overall, I took probably far too long to do this part, but did have fun doing it.  After I
# had finished, I read a really neat solution: to avoid confusion around keeping track of
# the addx counter separately, when you read an addx instruction when parsing your input,
# you can put a noop before it, and that will handle the cycling correctly!  I thought that
# was brilliant; if only I had thought of that!


### Parse input

@enum InstructionCommand noop addx

struct Instruction
    inst::InstructionCommand
    val::Union{Nothing, Int}
end

function parse_input(data_file::String)
    data = Instruction[]

    for line in eachline(data_file)
        d = split(line)
        if length(d) == 1
            @assert first(d) == "noop"
            push!(data, Instruction(noop, nothing))
        else
            @assert first(d) == "addx"
            v = parse(Int, last(d))
            push!(data, Instruction(addx, v))
        end
    end

    return data
end


### Part 1

function part1(instructions::Vector{Instruction})
    # Set changeable values such as Register X, the resume (which
    # is a sum of the product of X at various points in time), and
    # the instruction count, to keep track of the instruction we are
    # currently processing
    X, res, inst_cnt = 1, 0, 0

    # Iterate over instructions
    for inst in instructions
        # Handling from different instruction types
        if inst.inst == noop
            inst_cnt += 1
        elseif inst.inst == addx
            @assert !isnothing(inst.val)

            # Each addx instruction takes two cycles to
            for _ in 1:2
                inst_cnt += 1

                # Add the "signal strength" to the result, if we are
                # at the 20th (+ n*40) cycle
                if iszero((inst_cnt - 20) % 40)
                    res += X * inst_cnt
                end
            end

            # After the two addx cycles, we update Register X
            X += inst.val
        end
    end

    return res
end


### Part 2

function write_pixel!(io::IOBuffer, X::Int, inst_cnt::Int, screen_width::Int)
    i = mod1(inst_cnt + 1, screen_width)
    c = X ≤ i ≤ (X + 2) ? '█' : ' '
    print(io, c)
    return io
end

function part2(instructions::Vector{Instruction})
    # Set screen width, and changeable values
    # X is the register value, which denotes the centre position
    # of the sprite.  Instruction count is also defined to determine
    # the cursor of the CRT.  addx count is defined to keep track of
    # how to handle addx instructions taking multiple cycles to complete
    screen_width = 40
    X, inst_cnt, addx_cnt, inst_idx = 1, 0, 0, 1

    # Initialise IO buffer, and take first instruction
    io = IOBuffer()
    instruction = instructions[inst_idx]

    # The idea is to iterate over the instructions one at a time,
    # until we can't do so any longer.  Each iteration we perform the
    # correct operations as described in the problem
    while true
        # Print a new line if we are at the end of the line
        if iszero(inst_cnt % screen_width) && !iszero(inst_cnt)
            println(io)
        end

        # Handling for different instruction types
        if instruction.inst == noop
            write_pixel!(io, X, inst_cnt, screen_width)
        elseif instruction.inst == addx
            write_pixel!(io, X, inst_cnt, screen_width)
            addx_cnt += 1

            # If we have finished processing the addx instruction,
            # reset addx_cnt, and add to Register X
            if addx_cnt == 2
                addx_cnt = 0
                X += instruction.val
            end
        end

        # Increment the instruction count (representative of the cursor
        # of the CRT)
        inst_cnt += 1

        # If we are not currently
        if addx_cnt == 0
            # If we have reached the end of our input instructions, and have
            # finished with the current loop, we are done
            if inst_idx >= length(instructions)
                break
            end

            # Otherwise, pop another instruction from our input
            inst_idx += 1
            instruction = instructions[inst_idx]
        end
    end

    return String(take!(io))
end


### Main

function main()
    data = parse_input("data10.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 12740
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    println("Part 2: \n$part2_solution")
    @assert part2_solution == """\
███  ███  ███   ██  ███   ██   ██  ████ \n\
█  █ █  █ █  █ █  █ █  █ █  █ █  █ █    \n\
█  █ ███  █  █ █  █ █  █ █  █ █    ███  \n\
███  █  █ ███  ████ ███  ████ █ ██ █    \n\
█ █  █  █ █    █  █ █ █  █  █ █  █ █    \n\
█  █ ███  █    █  █ █  █ █  █  ███ █    """
end

main()
