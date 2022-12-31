# I really enjoyed today!  Parsing was a little tricky; we were given some interestingly
# formatted data for eight monkeys.  Essentially, monkeys are playing with out things; each
# monkey had a number of starting items (each item is identifiable with an integer).  Each
# monkey also has an operation: for each item they have, they perform an operation on it,
# and hand it to one of two monkeys depending on the item's value after the operation.  The
# item changes value according to the operation and goes to the appropriate monkey.
#
# For part one, we had to simulate the monkeys throwing our items around for 20 rounds.
# Importantly, for part 1, each monkey divides the item's value by 3 after their operation,
# before passing it on to the next monkey.  This was simply enough to simulate.
#
# Part two made me think for a while!  Everyone's input has one money who is squaring the
# items before passing it on.  However, we no longer divide by 3 after performing the
# operation on the items.  Therefore, the items' values grow exponentially large (just like
# the fishes from last year!  Classic Eric).  I thought for a while, and we must find some
# way of reducing the values of the items whilst keeping all important information (i.e., is
# the value still divisible correctly any of the monkeys).  I realised that, before any
# monkey passes the item on, we can divide the value by the least common multiple of all
# monkeys' divisors (i.e., the value they divide by to perform the test), as this will
# correctly reduce the size of the input while keeping enough information to process
# correctly!  Indeed, this is what I implemented, and it worked correctly.  I know this is
# probably rather trivial to many, but it made me think, and I really enjoyed the moment
# when I realised what to do (though it took me a little while longer, after realising what
# to do, to realise that the LCM had to be of _all_ monkeys, not just the current monkey and
# the monkey to which it passes...).


### Parse input

mutable struct Monkey
    n::Int
    items::Vector{Int}
    op::Expr
    test_div::Int
    true_monkey::Int
    false_monkey::Int
    items_inspected::Int
end


function parse_input(data_file::String)
    data = split(read(data_file, String), "\n\n")

    monkeys = Dict{Int,Monkey}()
    for d in data
        isempty(strip(d)) && continue
        lines = split(strip(d), "\n")

        # Parse Monkey number
        line = lines[1]
        monkey_n = split(first(split(line, ':')))
        n = parse(Int, last(monkey_n))

        # Parse initial state items
        line = lines[2]
        items_str = split(last(split(line, ": ")), ", ")
        starting_items = [parse(Int, i) for i in items_str]

        # Parse expression/operation
        line = lines[3]
        op = Meta.parse(last(split(line, ": ")))

        # Parse test case
        line = lines[4]
        test_str = last(split(line, ": "))
        test_div_by = parse(Int, last(split(test_str)))

        # Parse test results
        t_str, f_str = lines[5:6]
        true_monkey = parse(Int, last(split(t_str)))
        false_monkey = parse(Int, last(split(f_str)))

        # Construct Monkey and push to results
        monkey = Monkey(n, starting_items, op, test_div_by, true_monkey, false_monkey, 0)
        monkeys[n] = monkey
    end

    return monkeys
end


### Part 1

eval_expr(ex::Expr, old::Int) = Meta.eval(Base.Cartesian.lreplace(ex, :old, old))


function top_2_max(A)
    A = deepcopy(A)
    first_max, i = findmax(A)
    deleteat!(A, i)
    second_max = maximum(A)
    return first_max, second_max
end


get_result(monkeys) = prod(top_2_max(Int[m.items_inspected for m in monkeys]))


function part1(monkeys::Dict{Int,Monkey})
    monkeys = deepcopy(monkeys)

    # Do 20 rounds
    for _ = 1:20
        # For each monkey number
        for n = 0:(length(monkeys)-1)
            monkey = monkeys[n]

            # Process all of this monkey's items
            while !isempty(monkey.items)
                item = popfirst!(monkey.items)
                monkey.items_inspected += 1

                # Apply operation to worry level
                worry_level = eval_expr(monkey.op, item)

                # The monkey has finished inspection; div by 3
                worry_level ÷= 3

                # Determine the monkey to which this monkey throws the item to, and pass it on
                new_monkey_n =
                    mod(worry_level, monkey.test_div) == 0 ? monkey.true_monkey :
                    monkey.false_monkey
                push!(monkeys[new_monkey_n].items, worry_level)
            end
        end
    end

    return get_result(values(monkeys))
end


### Part 2

function part2(monkeys::Dict{Int,Monkey})
    monkeys = deepcopy(monkeys)

    # As we are doing more rounds, and we are no longer dividing by 3, each
    # item's worry level gets rather large.  To mitigate this, I figured we
    # need some way to reduce the worry number whilst keeping the information
    # we need.  What information do we need?  We need to retain information
    # about the current worry level, and its relation to the monkeys' divisors.
    # The way to do this is to compute the least common multiplier (LCM) of all
    # monkeys' divisors, and reduce the number by finding the worry level modulo
    # this value
    L = lcm((m.test_div for m in values(monkeys))...)

    # Do 10,000 rounds
    for rᵢ = 1:10_000
        for n = 0:(length(monkeys)-1)
            monkey = monkeys[n]

            # Process all of this monkey's items
            while !isempty(monkey.items)
                item = popfirst!(monkey.items)
                monkey.items_inspected += 1

                # Apply operation to worry level, and reduce it by the LCM
                worry_level = eval_expr(monkey.op, item)
                worry_level %= L

                # Determine the new monkey to which this monkey throws the item to, and pass it on
                new_monkey_n =
                    mod(worry_level, monkey.test_div) == 0 ? monkey.true_monkey :
                    monkey.false_monkey
                push!(monkeys[new_monkey_n].items, worry_level)
            end
        end
    end

    return get_result(values(monkeys))
end


### Main

function main()
    data = parse_input("data11.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 56350
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 13954061248
    println("Part 2: $part2_solution")
end

main()
