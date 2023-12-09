# This day was very interesting.  It's essentially a game of poker. There are 7
# different kinds of hands that you can get, and we needed to sort the input based
# on the higher scoring hands.  The value in the input is the bet amount for that
# hand.
#
# Part 1 was straight forward.  We had sort the input based on hand classification
# and calculate the response.
#
# Part 2 took me much longer than I care to admit.  We had to do the same, but the
# Js were now jokers and could be used for anything!  I thought it would be easy
# enough to extend code for part 1, but I had a lot of different bugs.  I had copy
# errors using the wrong card set; mistakes where I forgot to decrement the number
# of jokers available after using them.  The full house classification was the bane
# of my existence, and I ended up getting a working solution using effectively brute
# force:
#   https://github.com/jakewilliami/advent-of-code/blob/c121f03a/2023/day07/day07.jl#L230
# The following was helpful in developing a cleaner/more efficient solution for this
# function:
#   https://www.reddit.com/r/adventofcode/comments/18cr4xr/
# The problem was simple by I am stupid so I found part 2 a little tricky.  Fun, though!

using Base.Iterators
using OrderedCollections, StatsBase


### Parse Input ###

CARDS = "AKQJT98765432"
CARDS_WITH_JOKERS = "AKQT98765432J"
@assert Set(CARDS) == Set(CARDS_WITH_JOKERS)

struct Hand
    hand::String
    bet::Int

    function Hand(hand::S, n::Int) where {S <: AbstractString}
        @assert length(hand) == 5
        hand = uppercase(hand)
        @assert all(c in CARDS for c in hand)
        new(String(hand), n)
    end
end

Base.unique(hand::Hand) = join(unique(hand.hand))
StatsBase.countmap(hand::Hand) = countmap(hand.hand)
Base.convert(::AbstractDict{T, I}, h::Hand) where {T, I <: Integer} = countmap(hand)

function parse_input(input_file::String)
    L = [split(l) for l in eachline(input_file)]
    return Hand[Hand(a, parse(Int, b)) for (a, b) in L]
end

@enum HandType begin
    five_of_a_kind = 1
    four_of_a_kind
    full_house
    three_of_a_kind
    two_pair
    one_pair
    high_card
    none
end

### Helpers ###

# The `has_counts' function checks that some count map `D' contains
# the count or counts specified.  For example,
#   julia> @assert has_counts(Hand("QQVPM", 0), 1)
#   julia> @assert has_counts(Hand("QQVVM", 0), (2, 2))
#   julia> @assert !has_counts(Hand("QQVPM", 0), (2, 2))
#   julia> @assert has_counts(Hand("QQVPM", 0), (2, 1, 1))
has_counts(D::AbstractDict{T, Int}, n::I) where {T, I <: Integer} =
    any(v == n for v in values(D))
function has_counts(D::AbstractDict{T, I}, Ns) where {T, I <: Integer}
    Ns = countmap(Ns)
    for (k, v) in Ns
        occurrences = sum(dv == k for (dk, dv) in D)
        v == occurrences || return false
    end

    return true
end
has_counts(h::Hand, n) = has_counts(countmap(h), n)


### Part 1 ###

# A card is `n' of a kind if at least one card occurs n (or more) times
# in the hand
is_n_of_a_kind(D::AbstractDict{T, I}, n::Int) where {T, I <: Integer} =
    !isnothing(findfirst(v -> v >= n, D))
is_n_of_a_kind(hand::Hand, n::Int) = is_n_of_a_kind(countmap(hand), n)

# As we have the `is_n_of_a_kind' function, we can utilise it here
is_5_of_a_kind(hand) = is_n_of_a_kind(hand, 5)
is_4_of_a_kind(hand) = is_n_of_a_kind(hand, 4)
is_3_of_a_kind(hand) = is_n_of_a_kind(hand, 3)

# A card should be considered full house if it has 3 occurrences of
# one card and 2 of another
is_full_house(hand) = has_counts(hand, (3, 2))

# We can calculate the number of pairs in the countmap of a hand.
# Using this, it is trivial to check if the number of pairs is 1 or 2
n_pairs(hand::AbstractDict{T, I}) where {T, I <: Integer} = sum(v == 2 for (_, v) in hand)
n_pairs(hand::Hand) = n_pairs(countmap(hand))
is_2_pair(hand) = n_pairs(hand) == 2
is_1_pair(hand) = n_pairs(hand) == 1

# A high card contains five unique cards (no double-ups)
is_high_card(hand) = length(unique(hand)) == 5

# A card is scored based on its position in the card array:
# those that appear first have a higher value
function score_card(card::Char; cards = CARDS)
    i = findfirst(==(card), cards)
    return length(cards) - i + 1
end
score_card(h::Hand, i::Int; cards = CARDS) = score_card(h.hand[i], cards = cards)

# Using our various functions, we can classify the hand by finding the highest
# scoring matching pattern for the hand, and returning the corresponding HandType
function classify_hand(hand::Hand)
    scores = [
        is_5_of_a_kind,
        is_4_of_a_kind,
        is_full_house,
        is_3_of_a_kind,
        is_2_pair,
        is_1_pair,
        is_high_card,
        h -> true,
    ]
    i = findfirst(f -> f(countmap(hand)), scores)
    return HandType(i)
end

# Hands are scored such that the classification that appears earlier in the HandType
# enum has a greater score
function score_hand(hand::Hand, classify_fn::Function)
    type = classify_fn(hand)
    return length(instances(HandType)) - Int(type) + 1
end

# Calculate whether left and right hands are ordered in ascending order.  To do this,
# we need to score the hand (with the given classification function).  If they have the
# same type, we need to break the tie based on cards from left to right.
function _correct_order(left::Hand, right::Hand, classify_fn::Function; cards = CARDS)
    a, b = score_hand(left, classify_fn), score_hand(right, classify_fn)
    a != b && return a < b
    i = 1
    while i <= 5
        c1, c2 = score_card(left, i, cards = cards), score_card(right, i, cards = cards)
        c1 != c2 && return c1 < c2
        i += 1
    end
    error("Hopefully unreachable, ortherwise we have a tie (do we return false here?)")
end

# Overload the Ordering struct for a custom ordering type, providing support to `sort'
struct HandOrdering <: Base.Order.Ordering end
Base.Order.lt(_o::HandOrdering, a, b) =
    _correct_order(a, b, classify_hand; cards = CARDS)

function score_cards(data::Vector{Hand}, ordering::Base.Order.Ordering)
    res = 0
    for (i, h) in enumerate(sort(data, order = ordering))
        res += i * h.bet
    end
    return res
end

part1(data::Vector{Hand}) = score_cards(data, HandOrdering())


### Part 2 ###

# A card is `n' of a kind if at least one card occurs n (or more) times in the hand.  However,
# when taking jokers into consideration, any given card's count of occurances only has to be
# supplemented/augmented by the number of jokers.
function is_n_of_a_kind_with_jokers(D::AbstractDict{T, I}, n::Int) where {T, I <: Integer}
    is_n_of_a_kind(D, n) && return true
    js = pop!(D, 'J', 0)
    js == 0 && return false

    # If a card has count `v', and we want to reach n, then n - v must be within
    # the number of jokers we have available.  Note: because we already checked
    # for standard n of a kind, v must be < n.
    return !isnothing(findfirst(v -> (n - v) <= js, D))
end
is_n_of_a_kind_with_jokers(hand::Hand, n::Int) = is_n_of_a_kind_with_jokers(countmap(hand), n)

# As we have the `is_n_of_a_kind_with_jokers' function, we can utilise it here
is_5_of_a_kind_with_jokers(hand) = is_n_of_a_kind_with_jokers(hand, 5)
is_4_of_a_kind_with_jokers(hand) = is_n_of_a_kind_with_jokers(hand, 4)
is_3_of_a_kind_with_jokers(hand) = is_n_of_a_kind_with_jokers(hand, 3)

# The full house classification with jokers is decidedly the most complicated case.  Recall,
# we must have one card occurring 3 times and another occuring 2.  However, if we have jokers,
# we need to check if they are sufficient to supplement the cards with the count closest to
# 3 and 2 counts.
function is_full_house_with_jokers(D::AbstractDict{T, I}) where {T, I <: Integer}
    is_full_house(D) && return true
    js = pop!(D, 'J', 0)
    js == 0 && return false

    # Case 1: there are less than 2 distinct cards after jokers
    # have been removed from the hand.  In this case, you must
    # have a sufficient number of jokers to make up the full house
    if length(D) < 2
        # Case 1.1: the deck only consists of jokers, so you can
        # make a full house
        isempty(D) && return true

        # Case 1.2: the deck consists of one other card, so we need
        # to check that:
        #   a. the other card does not occur more than thrice; and
        #   b. there are a sufficient number of jokers to make up
        #      the desired deck
        v = last(only(D))
        v > 3 && return false
        return ((3 - v) + 2) <= js
    end

    # Case 2: we know there are at least 2 other distinct cards after
    # jokers have been removed from the hand.  We take the 2 with the
    # highest occurrences and try to use them to make up the desired
    # deck
    D = OrderedDict(D)
    sort!(D; byvalue = true, rev = true)
    (k1, v1), rest = Iterators.peel(D)
    (k2, v2), _rest = Iterators.peel(rest)

    # println(((k1, v1), (k2, v2)))

    # Case 2.1: If the most frequent card occurs more than 3 times, then
    # making a full house is impossible
    v1 > 3 && return false

    # Case 2.2: We must now check that the most frequent card can be augmented
    # by the jokers to make up 3
    (3 - v1) <= js || return false
    js -= (3 - v1)

    # Case 2.3: We do the same for the second most frequent
    v2 > 2 && return false
    return (2 - v2) <= js
end
is_full_house_with_jokers(hand::Hand) = is_full_house_with_jokers(countmap(hand))

# To have n pairs with jokers, we need to check that either the count itself already
# constitutes a pair, or that we can supplement the count up to 2 with some amount of
# jokers.  Hence, we can calculate the number of pairs with these two cases
function n_pairs_with_jokers(D::AbstractDict{T, I}) where {T, I <: Integer}
    js = pop!(D, 'J', 0)
    m = 0
    for v in values(D)
        if v >= 2
            # Case 1: the count of this card already constitutes a pair
            m += 1
        elseif (2 - v) <= js
            # Case 2: this card does not constitute a pair, but we can
            # make up a pair by supplementing this card with jokers
            js -= (2 - v)
            m += 1
        end
    end

    return m
end
n_pairs_with_jokers(hand::Hand) = n_pairs_with_jokers(countmap(hand))
is_2_pair_with_jokers(hand) = n_pairs_with_jokers(hand) == 2
is_1_pair_with_jokers(hand) = n_pairs_with_jokers(hand) == 1

# A high card with jokers means that either the hand is a traditional high card
# (without any jokers), or that you have n distinct cards and (5 - n) joker cards
# that make up the rest of the unique cards required for the high card pattern.
function is_high_card_with_jokers(D::AbstractDict{T, I}) where {T, I <: Integer}
    is_high_card(D) && return true
    js = pop!(D, 'J', 0)
    js == 0 && return false
    return (5 - length(D)) <= js
end
is_high_card_with_jokers(hand::Hand) = is_high_card_with_jokers(countmap(hand))

# Using our various functions, we can classify the hand by finding the highest
# scoring matching pattern for the hand, and returning the corresponding HandType.
# However, in this case, we want to classify the hand with the `_with_jokers'
# function variations.
function classify_hand_with_jokers(hand::Hand)
    scores = [
        is_5_of_a_kind_with_jokers,
        is_4_of_a_kind_with_jokers,
        is_full_house_with_jokers,
        is_3_of_a_kind_with_jokers,
        is_2_pair_with_jokers,
        is_1_pair_with_jokers,
        is_high_card_with_jokers,
        h -> true,
    ]
    i = findfirst(f -> f(countmap(hand)), scores)
    return HandType(i)
end

# Overload the Ordering struct for a custom ordering type, providing support to `sort'
struct HandOrderingWithJokers <: Base.Order.Ordering end
Base.Order.lt(_o::HandOrderingWithJokers, a, b) =
    _correct_order(a, b, classify_hand_with_jokers, cards = CARDS_WITH_JOKERS)

part2(data::Vector{Hand}) = score_cards(data, HandOrderingWithJokers())


### Main ###

function main()
    data = parse_input("data07.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 256448566
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 254412181
    println("Part 2: $part2_solution")
end

main()
