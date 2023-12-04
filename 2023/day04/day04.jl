struct Game
    id::Int
    mine::Set{Int}
    winning::Set{Int}
end

function parse_input(input_file::String)
    A = Game[]
    for line in eachline(input_file)
        s1, s2 = split(line, "|")
        s1a, s1b = split(s1, ":")
        _s1a, s1a = split(s1a)
        n = parse(Int, strip(s1a))
        l1 = Set(parse(Int, s) for s in split(s1b))
        l2 = Set(parse(Int, s) for s in split(s2))
        g = Game(n, l1, l2)
        push!(A, g)
    end
    return A
end

n_winning(game::Game) =
    length(game.mine ∩ game.winning)

function game_score(game::Game)
    wins = n_winning(game)
    wins == 0 && return 0
    return 2^(wins-1)
end

part1(data::Vector{Game}) =
    sum(game_score(game) for game in data)

function part2(data::Vector{Game})
    cards = Dict(g.id => g for g in data)
    card_counter = Dict{Int, Int}()

    # Initialise counter
    for game in data
        card_counter[game.id] = 1
    end

    # Add won "cards" to counter
    for (i, game) in enumerate(data)
        n_wins = n_winning(game)
        for _ in 1:card_counter[game.id], j in (i+1):(i+n_wins)
            if j <= length(data)
                card_counter[data[j].id] += 1
            end
        end
    end

    # Calculate answer
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
