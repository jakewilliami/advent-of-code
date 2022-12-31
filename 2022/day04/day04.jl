# On this day, we are given a list of ranges (on each line, two ranges of numbers).  Each
# range represents a section ID for which the elves are assigned cleaning (the elves are
# paired up, which is why there are two ranges on each line).
#
# Part 1 requires us to identify the number of pairs of elves whose section IDs overlap
# entirely (hence, redundant work).
#
# Part 2 asks us to find _any_ overlap of section IDs between the pairs of elves.
#
# I initially solved this using Julia's all function (checking that all IDs in range one are
# in range two, or vice versa).  Part 2 trivially changed this function to any.


# "a-b" or "a:b" -> a:b
function Base.parse(::Type{UnitRange{T}}, r_str::S) where {T <: Number, S <: AbstractString}
    s1, s2 = split(r_str, '-' ∈ r_str ? '-' : ':')
    return parse(T, s1):parse(T, s2)
end

function parse_input(data_file::String)
    data = Tuple{UnitRange{Int}, UnitRange{Int}}[]
    for line in readlines(data_file)
        s1, s2 = split(line, ',')
        r1, r2 = parse.(UnitRange{Int}, (s1, s2))
        push!(data, (r1, r2))
    end
    return data
end

function _solve_day_4(data::Vector{Tuple{UnitRange{Int}, UnitRange{Int}}}, f::Function)
    res = 0
    for (r1, r2) in data
        if f(i ∈ r2 for i in r1) || f(i ∈ r1 for i in r2)
            res += 1
        end
    end
    return res
end

part1(data::Vector{Tuple{UnitRange{Int}, UnitRange{Int}}}) = _solve_day_4(data, all)

part2(data::Vector{Tuple{UnitRange{Int}, UnitRange{Int}}}) = _solve_day_4(data, any)

function main()
    data = parse_input("data04.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 538
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 792
    println("Part 2: $part2_solution")
end

main()
