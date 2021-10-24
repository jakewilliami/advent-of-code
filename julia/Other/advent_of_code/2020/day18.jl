using DataStructures # for efficient queue and stack

@enum Operator begin
    plus
    times
    # left_parenthesis
    # right_parenthesis
end
@enum Parentheses begin
    left_parenthesis
    right_parenthesis
end

OPERATORS = Dict{Char, Union{Operator, Parentheses}}(
    '+' => plus,
    '*' => times,
    '(' => left_parenthesis,
    ')' => right_parenthesis
)

@assert (length(instances(Operator)) + length(instances(Parentheses))) == length(OPERATORS) "Exhaustive handling of operators"

function insert_if_valid!(V::AbstractVector{T}, i::Int, v::T) where {T}
    (isnothing(v) || isempty(v)) || insert!(V, i, v)
    return V
end
surrounding_indices(str::S, i::Integer) where {S <: AbstractString} =
    (prevind(str, i), nextind(str, i))
function surrounding_substrings(str::S, ch::Char) where {S <: AbstractString}
    j = findfirst(==(ch), str)
    k, l = surrounding_indices(str, j)
    return SubString(str, 1, k), SubString(str, l)
end

function tokenise_line(line::String)
    tokens = split(line)
    
    # No extra handling required if the line does not contain parentheses
    (contains(line, '(') || contains(line, ')')) || return tokens
    
    # handle parentheses correctly
    i = 1
    while i <= length(tokens)
        token = tokens[i]
        while contains(token, '(') && i <= length(tokens)
            deleteat!(tokens, i)
            a, b = surrounding_substrings(token, '(')
            insert_if_valid!(tokens, i, b)
            insert_if_valid!(tokens, i, a)
            insert!(tokens, i, SubString("("))
            i += 1
            if i <= length(tokens)
                token = tokens[i]
            end
        end
        while contains(token, ')') && i <= length(tokens)
            deleteat!(tokens, i)
            a, b = surrounding_substrings(token, ')')
            insert!(tokens, i, SubString(")"))
            insert_if_valid!(tokens, i, b)
            insert_if_valid!(tokens, i, a)
            i += 1
            if i <= length(tokens)
                token = tokens[i]
            end
        end
        i += 1
    end
    
    return tokens
end

function parse_tokens(tokens::Vector{S}) where {S <: AbstractString}
    # put everything on a stack and parse as reverse Polish notation (postfix)
    # I will use the Shunting-yard algorithm:
    # https://stackoverflow.com/a/2969583/12069968
    # https://www.wikiwand.com/en/Shunting-yard_algorithm
    output_queue = Queue{Union{Int, Operator, Parentheses}}()
    op_stack = Stack{Union{Operator, Parentheses}}()
    
    while !isempty(tokens)
        token = popfirst!(tokens)
        if all(isdigit(c) for c in token) # token is a number (specifically an integer)
            enqueue!(output_queue, parse(Int, token))
        # elseif token ∈ keys(FUNCTIONS) # token is a function
        elseif length(token) == 1 && only(token) ∈ keys(OPERATORS) && OPERATORS[only(token)] isa Operator # token is an operator o1
            while !isempty(op_stack) && first(op_stack) != OPERATORS['('] # && (o2 has greater precedence than o1 *or* they have the same precedence and o1 is left-associative)
                op₂ = pop!(op_stack)
                enqueue!(output_queue, op₂)
            end
            op₁ = OPERATORS[only(token)]
            push!(op_stack, op₁)
        elseif length(token) == 1 && only(token) == '(' # token is a left parenthesis
            op = OPERATORS[only(token)]
            push!(op_stack, op)
        elseif length(token) == 1 && only(token) == ')' # token is a right parenthesis
            while !isempty(op_stack) && first(op_stack) != OPERATORS['(']
                # If the stack runs out without finding a left parenthesis, then there are mismatched parentheses
                @assert !isempty(op_stack) "Mismatched parentheses"
                op = pop!(op_stack)
                enqueue!(output_queue, op)
            end
            @assert first(op_stack) == OPERATORS['(']
            pop!(op_stack)
            # if there is a function token at the top of the operator stack, then:
            #     pop the function from the operator stack into the output queue
            # if !isempty(op_stack) && first(op_stack) isa Operator
            #     op = pop!(op_stack)
            #     enqueue!(output_queue, op)
            # end
        end
    end
    # After the while loop, pop the remaining items from the operator stack into the output queue.
    while !isempty(op_stack)
        # pop the operator from the operator stack onto the output queue
        op = pop!(op_stack)
        # If the operator token on the top of the stack is a parenthesis, then there are mismatched parentheses.
        @assert op != OPERATORS['('] "Mismatched parentheses"
        enqueue!(output_queue, op)
    end
    
    return output_queue
end

function evaluate(q::Queue{Union{Int, Operator}})
    # We need to maintain a stack for reverse polish notation to work
    # it is actually super easy to evaluate the queue in this way
    s = Stack{Int}()
    while !isempty(q)
        x = dequeue!(q)
        if x isa Integer
            push!(s, x)
        elseif x isa Operator
            a = pop!(s)
            b = pop!(s)
            if x == OPERATORS['+']
                push!(s, a + b)
            elseif x == OPERATORS['*']
                push!(s, a * b)
            else
                error("Exhaustive handling of operators")
            end
        else
            error("Exhaustive handling of operators")
        end
    end
    @assert length(s) == 1 "Outstanding tokens in queue which need to be handled"
    return pop!(s)
end
evaluate(tokens::Vector{S}) where {S <: AbstractString} = evaluate(parse_tokens(tokens))
evaluate(line::String) = evaluate(parse_tokens(tokenise_line(line)))

part1(lines::Vector{String}) = sum(evaluate(line) for line in lines)
part1(path::String) = part1(readlines(path))

@assert evaluate("1 + 2 * 3 + 4 * 5 + 6") == 71
@assert evaluate("1 + (2 * 3) + (4 * (5 + 6))") == 51
@assert evaluate("2 * 3 + (4 * 5)") == 26
@assert evaluate("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437
@assert evaluate("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240
@assert evaluate("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632

part1("inputs/data18.txt")
