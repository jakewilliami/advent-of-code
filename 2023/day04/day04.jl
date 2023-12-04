using AdventOfCode.Parsing

using DataStructures

function parse_input(input_file::String)
    A = []
    for line in eachline(input_file)
        s1, s2 = split(line, "|")
        l1, l2 = get_integers(s1), get_integers(s2)
        push!(A, (l1[1], (l1[2:end], l2)))
    end
    return A
end

function n_winning(card)
    winning, mine = card
    wins = 0
    for a in mine
        if a in winning
            wins += 1
        end
    end
    return wins
end

function card_score(card)
    wins = n_winning(card)
    return wins == 0 ? 0 : 2^(wins-1)
end

function part1(data)
    res = 0
    for (card_n, card) in data
        res += card_score(card)
    end
    return res
end

function part2(data)
    cards = Dict(k => v for (k, v) in data)
    card_counter = DefaultDict{Int, Int}(0)

    # Initialise counter
    for (card_n, _card) in data
        card_counter[card_n] += 1
    end

    for (i, (card_n, card)) in enumerate(data)
        n_wins = n_winning(card)
        for _ in 1:card_counter[card_n], j in (i+1):(i+n_wins)
            if j <= length(data)
                card_counter[data[j][1]] += 1
            end
        end
    end

    return sum(values(card_counter))
end

function main()
    data = parse_input("data04.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 21568
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 11827296
    println("Part 2: $part2_solution")
end

main()
