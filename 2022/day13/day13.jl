function parse_input(data_file::String)
    data = Tuple{Any, Any}[]
    contents = read(data_file, String)
    for p in eachsplit(contents, "\n\n")
        left, right = Meta.eval.(Meta.parse.(split(p, '\n')))
        push!(data, (left, right))
    end
    return data
end


# Ordering

@enum PacketOrder correct incorrect indeterminate


function correct_order(left::Integer, right::Integer)
    left < right && return correct
    left == right && return indeterminate
    return incorrect
end


function correct_order(left::AbstractVector, right::AbstractVector)
    for (a, b) in zip(left, right)
        ord = correct_order(a, b)
        ord != indeterminate && return ord
        if ord == incorrect
            return incorrect
        end
    end
    return correct_order(length(left), length(right))
end


correct_order(left::I, right::AbstractVector) where {I <: Integer} =
    correct_order(I[left], right)
correct_order(left::AbstractVector, right::I) where {I <: Integer} =
    correct_order(left, I[right])


# Part 1

function part1(data::Vector{NTuple{2, T}}) where {T}
    res = 0
    for (i, (left, right)) in enumerate(data)
        # If the order of the present pair is correct, add its index to result
        correct_order(left, right) == correct && (res += i)
    end
    return res
end


# Part 2

struct PacketOrdering <: Base.Order.Ordering end
Base.Order.lt(_o::PacketOrdering, a, b) = correct_order(a, b) == correct


function part2(data::Vector{NTuple{2, T}}) where {T}
    dividers = ([[2]], [[6]])

    # Collate all packets into list and add dividers
    packets = collect(Base.Iterators.flatten(data))
    append!(packets, dividers)

    # Sort packets according to the correct_order
    sort!(packets, order = PacketOrdering())

    # Find the divider indices and return their product (our answer)
    i = findfirst(==(first(dividers)), packets)
    j = findfirst(==(last(dividers)), packets)
    @assert all(!isnothing(m) for m in (i, j))
    return i * j
end


# Main

function main()
    data = parse_input("data13.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 5506
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 21756
    println("Part 2: $part2_solution")
end

main()
