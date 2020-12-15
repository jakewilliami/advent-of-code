using DelimitedFiles: readdlm

const datafile = "inputs/data13.txt"

function parse_input(datafile::String)
    data = readdlm(datafile, ',')
    return data[1, 1], data[2, :]
end

function catch_nearest_bus(input::NTuple{2, Any})
    earliest_timestamp, IDs = input
    viable_options = NTuple{2, Int}[(ID, ID * cld(earliest_timestamp, ID)) for ID in IDs if ID ≠ "x"]
    earliest_bus_id, earliest_bus_timestamp = viable_options[argmin(Int[last(x) for x in viable_options])]
    
    return (earliest_bus_timestamp - earliest_timestamp) * earliest_bus_id
end

@time println(catch_nearest_bus(parse_input(datafile)))

function find_timestamp(input::NTuple{2, Any})
    rubbish, IDs = input
    data = NTuple{2, Int128}[(IDs[ID_idx], ID_idx - 1) for ID_idx in 1:length(IDs) if IDs[ID_idx] ≠ "x"]
    first_ID, t = first(first(IDs)), ifelse(last(last(data)) > 7, 100000000000000, 0) # the problem suggest that our input (much larger than the test input) will easily be at least 100000000000000

    while true
        timestamps = NTuple{2, Int128}[(ID, t + consec_shift) for (ID, consec_shift) in data]
        departures = Int128[ID * cld(timestamp, ID) for (ID, timestamp) in timestamps]
        
        if isequal(Int128[timestamp for (ID, timestamp) in timestamps], departures)
            return t
        else
            t += first_ID
        end
    end
    
    return nothing
end

@time println(find_timestamp(parse_input(datafile)))