using StatsBase, OrderedCollections

CARDS = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']
CARDS2 = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J']
MAIN_PRINT = false
PRINTED = []

struct Hand
    hand::String
    bet::Int

    function Hand(hand::S, n::Int) where {S <: AbstractString}
        # @assert length(hand) == 5
        hand = uppercase(hand)
        @assert all(c in CARDS for c in hand)
        new(String(hand), n)
    end
end

# TODO: validate these
function parse_input(input_file::String)
    L = readlines(input_file)
    L = [split(l) for l in L]
    return [Hand(a, parse(Int, b)) for (a, b) in L]
end

function _is_noak(D, n)
    for (k, v) in D
        v >= n && return true, k
    end
    return false, Char(0)
end
function is_noak(hand::Hand, n)
    D = countmap(hand.hand)
    for v in values(D)
        v >= n && return true
    end
    return false
end

is_5oak(hand::Hand) = is_noak(hand, 5)
is_4oak(hand::Hand) = is_noak(hand, 4)
is_3oak(hand::Hand) = is_noak(hand, 3)
function is_fh(hand::Hand)
    D = countmap(hand.hand)
    has_3, card_3 = _is_noak(D, 3)
    has_3 && pop!(D, card_3)
    has_2, card_2 = _is_noak(D, 2)
    return has_3 && has_2
end
function np(hand::Hand)
    D = countmap(hand.hand)
    m = 0
    for v in values(D)
        if v >= 2
            m += 1
        end
    end
    return m
end
is_p(hand::Hand, n) = np(hand) == n
is_2p(hand::Hand) = is_p(hand, 2)
is_1p(hand::Hand) = is_p(hand, 1)
is_hi(hand::Hand) = length(countmap(hand.hand)) == 5

function score_card(card::Char; cards = CARDS)
    # I was still using CARDS rather than the kwarg in this function for part 2...
    i = findfirst(==(card), cards)
    return length(cards) - i + 1
end

function score_hand(hand::Hand)
    scores = [is_5oak, is_4oak, is_fh, is_3oak, is_2p, is_1p, is_hi, h -> true]
    i = findfirst(f -> f(hand), scores)
    return length(scores) - i + 1
    if is_5oak(hand)
        return 6
    elseif is_4oak(hand)
        return 5
    elseif is_fh(hand)
        return 4
    elseif is_3oak(hand)
        return 3
    elseif is_2p(hand)
        return 2
    elseif is_1p(hand)
        return 1
    end
    return 0
end

function _correct_order(left::Hand, right::Hand, sh, sc)
    a, b = sh(left), sh(right)
    a != b && return a < b
    i = 1
    while i <= 5
        c1, c2 = sc(left.hand[i]), sc(right.hand[i])
        c1 != c2 && return c1 < c2
        i += 1
    end
    error("Hopefully unreachable")
end

correct_order(left::Hand, right::Hand) = _correct_order(left, right, score_hand, score_card)

struct HandOrdering <: Base.Order.Ordering end
Base.Order.lt(_o::HandOrdering, a, b) = correct_order(a, b)

function score_cards(data, ordering)
    res = 0
    for (i, h) in enumerate(sort(data, order = ordering))
        res += i * h.bet
    end
    return res
end

part1(data) = score_cards(data, HandOrdering())

score_card2(card::Char) = score_card(card, cards=CARDS2)

function has_counts(D, n::Int)
    for v in values(D)
        if v == n
            return true
        end
    end
    return false
end

function has_counts(D, Ns)
    Ns = countmap(Ns)
    # D: 'a' => 1, 'b' => 2, 'c' => 2
    # Ns: 2 => 2, 1 => 1
    for (k, v) in Ns
        # for example, if k = 2, v = 1, we want to check that 2 occurs exactly once as a count in D
        occurrences = sum(dv == k for (dk, dv) in D)
        v == occurrences || return false
    end


    return true

    return D == Ns

    Ns = Set(Ns)
    Vs = Set{eltype}()
    for v in values(D)
        if v in Ns
            push!(Vs, v)
        end
    end
    # println(Vs, Ns)
    return Ns == Vs
end

function has_counts(D, Ns...)
    return all(has_counts(D, n) for n in Ns)
end

function _is_noak2(hand::Hand, n::Int)
    D = countmap(hand.hand)
    js = pop!(D, 'J', 0)

    # J cards can pretend to be whatever card is best for the purpose of determining hand type
    # I think we need to do this differently
    for c in CARDS2
        m = get(D, c, 0)
        if (n - m) <= js
            return true, c
        end
    end
    return false, Char(0)

    c = Char(0)
    for (k, v) in D
        if v >= n
            c = k
            break
        end
    end
    is_noak(hand, n) && js < n && return true, c
    js = pop!(D, 'J', 0)  # TODO: get or pop!?
    for (k, v) in D
        @assert v < n
        if (n - v) <= js
            return true, k
        end
    end
    return false, Char(0)
end

function is_noak2(hand::Hand, n::Int)
    is_noak(hand, n) && return true

    has_n, card_n = _is_noak2(hand, n)
    return has_n


    D = countmap(hand.hand)
    # println("$n of a kind ($(hand.hand)): ", D)
    js = pop!(D, 'J', 0)  # TODO: get or pop!?

    return any((js == (n - i) && has_counts(D, i)) for i in 0:5)
    return (js == (n - 1) && has_counts(D, n))


    # println(D, "   ", js)
    for v in values(D)
        # println(v)
        @assert v < n
        # println("($n - $v) >= $js: ($((n - v) >= js))")
        # if (n - v) >= (n - js)
        if (n - v) <= js
            return true
        end
    end
    return false
end
is_5oak2(hand::Hand) = is_noak2(hand, 5)
is_4oak2(hand::Hand) = is_noak2(hand, 4)
is_3oak2(hand::Hand) = is_noak2(hand, 3)
function is_fh2(hand::Hand)
    # TODO: clean up
    # println("hii")
    is_fh(hand) && return true
    D = countmap(hand.hand)
    js = pop!(D, 'J', 0)
    D2 = countmap(values(D))

    return (js == 1 && has_counts(D, (2, 2))) || (js == 2 && has_counts(D, (2, 1))) || (js == 3 && has_counts(D, (1, 1))) || (js == 4 && has_counts(D, 2)) || (js == 5 && has_counts(D, 1))

    return js == 1 && has_counts(D, (2, 2))

    # The only way to get full house with jokers is if you have 1 joker, and 2x2 other things
    return get(D2, 2, 0) == 2 && js == 1

    if isempty(D)
        @assert js == 5
        return true
    end
    # println("hi")

    has_3, card_3 = _is_noak2(hand, 3)
    # println(hand.hand, " ", has_3, card_3, D)
    has_3 && pop!(D, card_3)
    isempty(D) && return false
    hand = Hand(join(collect(keys(D))), hand.bet)
    has_2, card_2 = _is_noak2(hand, 2)
    # println(hand.hand, " ", has_2, card_2, D)
    has_2 && pop!(D, card_2)
    isempty(D) && return false
    hand = Hand(join(collect(keys(D))), hand.bet)

    maxes = reverse(collect(sort(D)))
    k1, m1 = maxes[1]

    # println("!!! $js")
    if has_3 && js >= max(2 - m1, 0)
        println("Found $card_3 had 3 and $k1 had $m1 with $js jokers")
    end
    has_3 && return js >= max(2 - m1, 0)
    if has_2 && js >= max(3 - m1, 0)
        println("Found $card_2 had 2 and $k1 had $m1 with $js jokers")
    end
    has_2 && return js >= max(3 - m1, 0)

    length(maxes) >= 2 || return false
    k2, m2 = maxes[2]

    js_for_3 = max(3 - m1, 0)
    enough_js_for_3 = js >= js_for_3
    js = max(js - js_for_3, -1)
    js_for_2 = max(2 - m2, 0)
    enough_js_for_2 = js >= js_for_2

    if enough_js_for_3 && enough_js_for_2
        println("Found $k1 with $m1 and $k2 with $m2 and $js jokers ($js_for_3, $enough_js_for_3, $js_for_2, $enough_js_for_2)")
    end
    return enough_js_for_3 && enough_js_for_2
    return js <= (min(3 - m1, 0) + min(2 - m2, 0))

    found_3, found_2 = false, false
    for (k, v) in copy(D)
        if v == 3
            found_3 = true
            pop!(D, k)
        end
        if v == 2
            found_2 = true
            pop!(D, k)
        end
    end
    @assert !(found_3 && found_2)

    max2 = []
    maxvs = sort(collect(values(D)),rev=true)
    for (k, v) in D
        length(max2) == 2 && break
        if maxvs[1] == v
            push!(max2, k)
            popfirst!(maxvs)
        end
    end

    if isempty(max2)
        return false
    end

    m1 = D[max2[1]]
    if found_3
        return js <= min(2 - m1, 0)
    end
    if found_2
        return js <= min(3 - m1, 0)
    end
    if length(max2) < 2
        return false
    end
    m2 = D[max2[2]]
    return js <= ((3 - m1) + (2 - m2))
    return js <= (min(3 - m1, 0) + min(2 - m2, 0))
end
function is_p2(hand::Hand, n)
    is_p(hand, n) && return true
    npairs = np(hand)
    n -= npairs
    D = countmap(hand.hand)
    js = pop!(D, 'J', 0)
    m = 0
    for v in values(D)
        # println(hand, D, js)
        v >= 2 && continue
        @assert v != 2
        if (2 - v) <= js
            js -= (2 - v)
            m += 1
        end
    end
    return m == n
end
is_2p2(hand::Hand) = is_p2(hand, 2)
is_1p2(hand::Hand) = is_p2(hand, 1)
function is_hi2(hand::Hand)
    is_hi(hand) && return true
    D = countmap(hand.hand)
    js = pop!(D, 'J', 0)
    return (5 - length(D)) <= js
    return (5 - length(D)) >= js
end

function score_hand2(hand::Hand)
    scores = [is_5oak2, is_4oak2, is_fh2, is_3oak2, is_2p2, is_1p2, is_hi2, h -> true]
    i = findfirst(f -> f(hand), scores)
    if MAIN_PRINT && !(hand.hand in PRINTED)
        # if contains(hand.hand, 'J') && scores[i] in (is_2p2, is_1p2) #&& !(scores[i] in (is_fh2, is_3oak2, is_5oak2, is_4oak2))
            # println(hand.hand, ": ", scores[i], " <- ", countmap(hand.hand))
        # if get(countmap(hand.hand), 'J', 0) > 1
        # if scores[i] == is_3oak2 && contains(hand.hand, 'J')
        if contains(hand.hand, 'J')
            # println(hand.hand, ": ", scores[i], " <- ", countmap(hand.hand))
        end
        push!(PRINTED, hand.hand)
    end
    return length(scores) - i + 1
end

correct_order2(left::Hand, right::Hand) = _correct_order(left, right, score_hand2, score_card2)

struct HandOrderingWithJokers <: Base.Order.Ordering end
Base.Order.lt(_o::HandOrderingWithJokers, a, b) = correct_order2(a, b)

part2(data) = score_cards(data, HandOrderingWithJokers())

function main()
    # println(is_fh(Hand("T777T", 0)))
    # println(is_5oak2(Hand("JJJ8J", 0)))
    # h = Hand("J322A", 0)
    # println(is_fh2(h))
    # println(has_counts(countmap(h.hand), (2, 2)))
    data = parse_input("data07.txt")
    # data = [Hand("JQJJJ", 0), Hand("JJJJJ", 0), Hand("JJJ8J", 0)]
    # data = parse_input("data07.test.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 256448566
    println("Part 1: $part1_solution")

    # Part 2
    sorted = sort(data, order = HandOrderingWithJokers())
    # println("+"^20)
    io = IOBuffer()
    for h in sorted
        function f(io, h)
            scores = [is_5oak2, is_4oak2, is_fh2, is_3oak2, is_2p2, is_1p2, is_hi2, h -> true]
            for f in scores
                if f(h)
                    f == scores[end] ? print(io, "catchall") : print(io, f)
                    if f != scores[end]
                        print(io, ", ")
                    end
                end
            end
            return String(take!(io))
        end
        # println("$(h.hand) ($(score_hand2(h))): $(f(io, h))")
    end
    # println("+"^20)
    part2_solution = part2(data)
    @assert part2_solution == 254412181
    println("Part 2: $part2_solution")
    # not 253076657
    # not 253112265
    # not 253318025
    # not 253472802
    # not 254091927
    # not 254126629: too low
    #     254412181
    # not 254866135
    # not 256448566
    # not 258647104: too high
end

main()
