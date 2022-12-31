# We are given a long string which represents a signal from a communication device.  Within
# that signal is a marker: a series of packets (characters) that are all unique.
#
# Part 1 asks us to find the marker of length 4.  This was simple enough, to check that the
# number of unique characters in the window of length 4 is also 4.
#
# Part 2 simply asked us to change the marker length to 14, which was trivial as I coded
# this dynamically in the first place.


parse_input(data_file::String) = strip(read(data_file, String))

function _find_starting_marker(data::S, marker_len::Int) where {S <: AbstractString}
    for i in marker_len:length(data)
        c = data[(i - (marker_len - 1)):i]
        if length(unique(c)) == marker_len
            return Some(i)
        end
    end
end

part1(data::S) where {S <: AbstractString} = _find_starting_marker(data, 4)
part2(data::S) where {S <: AbstractString} = _find_starting_marker(data, 14)

function main()
    data = parse_input("data06.txt")

    # Part 1
    part1_solution = part1(data).value
    @assert part1_solution == 1647
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data).value
    @assert part2_solution == 2447
    println("Part 2: $part2_solution")
end

main()
