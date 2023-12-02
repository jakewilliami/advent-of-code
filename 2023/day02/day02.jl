# Input is lines of instances of games.  Each game, an elf will reach into a bag of cubes
# and pull out a set of coloured cubes.  This happens multiple times in a game.  So the game
# has an ID, as well as a number of sets of cubes that the elf pulls out of the bag.
#
# Part 1 of the problem wants us to add together all of the game IDs that use less than 13
# red cubes, less than 14 green cubes, and less than 15 blue cubes.  Part 2 wants us to add
# together the "power" of each game, where this power is defined as the product of the fewest
# number of cubes of each colouor that could have been in the bag to make the game possible

struct Cubes
    colour::Symbol
    count::Int
end

struct Game
    id::Int
    cubes::Set{Set{Cubes}}
end

function parse_cube(s::AbstractString)
    count_str, colour_str = split(s)
    count = parse(Int, count_str)
    return Cubes(Symbol(colour_str), count)
end
parse_cubes(s::AbstractString) = Set{Cubes}(parse_cube(p) for p in eachsplit(s, ", "))
parse_game(s::AbstractString) = Set{Set{Cubes}}(parse_cubes(p) for p in eachsplit(s, "; "))

function parse_input(input_file::String)
    A = Game[]
    for l in eachline(input_file)
        game_str, cubes_str = split(l, ": ")
        id = parse(Int, last(split(game_str)))
        game = parse_game(cubes_str)
        push!(A, Game(id, game))
    end
    return A
end

function game_is_possible(S::Set{Set{Cubes}})
    for s in S, c in s
        if (c.colour == :red && c.count > 12) ||
            (c.colour == :green && c.count > 13) ||
            (c.colour == :blue && c.count > 14)
            return false
        end
    end
    return true
end

function part1(data::Vector{Game})
    return sum(game_is_possible(a.cubes) ? a.id : 0 for a in data)
end

function power_of_game(S::Set{Set{Cubes}})
    D = Dict{Symbol, Int}(:red => 0, :green => 0, :blue => 0)
    for s in S, c in s
        if c.count > D[c.colour]
            D[c.colour] = c.count
        end
    end
    return prod(values(D))
end

function part2(data::Vector{Game})
    return sum(power_of_game(a.cubes) for a in data)
end

function main()
    data = parse_input("data02.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 2913
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 55593
    println("Part 2: $part2_solution")
end

main()
