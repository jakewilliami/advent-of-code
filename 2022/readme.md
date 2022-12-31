# Advent of Code, 2022

Advent of Code solutions for 2022.

Using Julia to initially solve the problems in the interest of solving the problems quickly.  I may then use another language to solve the problem again, in the interest of expanding my repertoire.

## Leaderboard

There also exists a [`leaderboard/`](../leaderboard/) subdirectory (which I made this year), which contains helper scripts to programmatically access the work leaderboard I set up!

## Reflection

### Goals

This year is the first year I have really tried to push myself with Advent of Code.  The previous two years I did it in my own time just for a bit of fun.  This year I used the leaderboard to motivate me to solve these as fast as possible.  (I set up a private leaderboard at work, and with a friend, as I will never get on the global leaderboard, but this provided plenty of motivation.)

Most days I would be sat at my computer at 6 p.m. (local time, when the problems were released) ready to try and solve the problems as soon as possible (except for a few days where I had dinner plans and had to do it later on, or could only do part 1 before going out for dinner).

On top of this, I pushed myself not to look for help when trying to solve the problems.  Only once I had solve the problem would I look at others' solutions.  For the large majority of questions, this was true, though I think there were a couple of days where I needed a tiny nugde in the right direction.

### Statistics

My best ranking globally was for part 1 of day 22, where I got 2271<sup>st</sup> in the world.  This may not seem impressive, but I am proud of it.  Annoyingly, it would have been better if I did not have a bug in my AdventOfCode.jl package, in which cardinal/orthogonal directions did not compute correctly for 3 dimensions.  (This took me a while to realise, and I kicked myself when I did.)  I attribute my success in this part largely to Julia's handling of multidimensional arrays, as well as somee collated functionality for multidimensional handling of common logic (in AdventOfCode.jl).

My second best ranking was 2990<sup>th</sup> on day 5, part 2, which was related to moving crates around.  I think I took far too long parsing the input programmatically (when it was simple enough to hard code, and would have made the initial solution much faster), but I think I did well in this because of my intimate understanding of arrays by reference and mutability in Julia.  I did exactly what part one told me to do: move boxes one by one (which in turn reversed the order of these being moved), using `pop!` and `pushfirst!`.  In part two, we take them all at the same time, so I knew to use `splice!` and `prepend!`.

The remaining 8 of my top 10 days/parts this year were:
  - Day 3 part 2 (rank 3048<sup>th</sup>);
  - Day 20 part 1 (rank 3164<sup>th</sup>);
  - Day 25 part 1 (rank 3318<sup>th</sup>);
  - Day 3 part 1 (rank 3368<sup>th</sup>);
  - Day 5 part 1 (rank 3381<sup>st</sup>);
  - Day 18 part 1 (rank 3409<sup>th</sup>);
  - Day 23 part 2 (rank 3596<sup>th</sup>); and
  - Day 4 part 2 (rank 3667<sup>th</sup>).

My average ranking for all days in 2022, at time of writing (having not completed 11 out of 50 parts) is 7587<sup>th</sup>.  Notwithstanding days where I had evening plans, this would be about 7203<sup>rd</sup>.

While I understand that this is probably not an amazing metric as this is not a proportion of the number of people who "competed", this is nice to think about global ranking.  And considering I've only been programming since late 2019, this is alright.

Day 3 was fun as Julia's builtin set operations meant that I could use the intersections of collections very easily.  Also, knowing about `Base.Iterators.partition` in part 2 made this easily adjustible for part 2 just 6 minutes after completing part 1

Day 20 part 1 was fun.  I remembered a solution from 2020 that used a doubly-linked list (which, since 2020, I had learned about), and realised that is the perfect use-case for such a data structure.  I used Tom Kwong's [CircularList.jl](https://github.com/tk3369/CircularList.jl) package for this, though there might be [something](https://juliacollections.github.io/DataStructures.jl/stable/circ_deque/) in [DataStructures.jl](https://github.com/JuliaCollections/DataStructures.jl) that I could use.

Day 18 part 1 was once again made very simple using Julia's Cartesian indices, and my common functionality package.  Part 2 was very difficult for me, as I thought I figured out a solution to do it but it turns out there were a few edge cases where my "solution" didn't work, so I had to use flood fill.

Day 4 was related to ranges (for which Julia has a native type), and part 1 was about finding the number of pairs of ranges <i>A</i> and <i>B</i> such that <i>a</i> &isin; <i>B</i> &forall; <i>a</i> in <i>A</i> or <i>b</i> &isin; <i>A</i> &forall; <i>b</i> in <i>B</i>.  For this, I did this naïvely using the `all` function in Julia, and iterating over the range.  Part two was finding the number of pairs of ranges <i>A</i> and <i>B</i> such that &exist; <i>a</i> in <i>A</i> where <i>a</i> &isin; <i>B</i>, <i>or</i> vice versa for <i>b</i> &isin; <i>A</i>.  As I approached part 1 naïvely, all I had to do for part 2 was to change `all` to `any`.  This is likely why part 2 for day 4 is in my top 10, and why it only took me 31 seconds after completing part 1.

My next fastest part 2 was day 6, , which took 41 seconds to finish after doing part 1, as I had already made the market length a variable, so all I had to do was change that variable from 4 to 14.  After that, day 1 part 2 took only 2 minutes and 26 seconds to solve after finishing part 1; day 5 took 2 minutes and 52 seconds after part 1; and day 23 took 3 minutes and 26 seconds after completing part 1 (on that note, I ranked somewhat well on this day/part; see above for comments).

In terms of fastest complete days (i.e., completing both part 1 and 2 in shortest amount of time), my top 10 were:
  - Day 1 (7 minutes, 21 seconds);
  - Day 6 (8 minutes, 24 seconds);
  - Day 3 (11 minutes, 12 seconds);
  - Day 4 (12 minutes, 3 seconds);
  - Day 2 (18 minutes, 48 seconds);
  - Day 10 (20 minutes, 53 seconds);
  - Day 5 (22 minutes, 15 seconds);
  - Day 18 (34 minutes, 37 seconds);
  - Day 8 (43 minutes, 19 seconds); and
  - Day 11 (51 minutes).

Naturally, the earlier days were solved faster.  Nothing much else is to be said on the speed at which I solved the puzzles; only that I hope to see gradual improvement over the years.

### Thoughts

My favourite days are probably the ones that brought out Julia's strengths, or those that used maths;
  - Day 3, using Julia's intersections, made the solution very clean;
  - Day 11&mdash: proud to have figured out part 2, using LCM;
  - Day 13''s solution felt very idiomatic, using Julia's multiple dispatch for comparison on different types, and extending Julia's `Ordering` API;
  - Days 16/19&mdash;: more than fun was the learning that came from it, but it's cool to have recognised clear linear optimisation problems (linear programming) in this!  Still unfinished though, so should probably consider using graph theory over LP...; and
  - Day 21&mdash;: using systems of non-linear equations to solve this was really cool!  Overall a quite fun day.

As my goal was to do as much of these problems as possible _on my own_, there were many days which really helped me to develop my skills and learn different areas of programming:
  - Day 7 was a good excercise on recursion, which I don't do enough of;
  - Day 11 (using Julia's `Meta.parse`, and finding out about `Base.Cartesian.lreplace`) was neat, and using LCM (as previous stated) was really cool;
  - Day 12 was a useful excercise on graph theory/path finding, which turned out to be a useful start on these problems for a few other days this year;
  - Day 15&mdash;: I am not convinced my solution is very optimal (especially for part 2; this is the sensors and beacons day), but it was an interesting problem that made me think a lot about different ways to solve this;
  - Day 16 (and 19) were tricky optimisation problems (which, at time of writing, I still haven't completed).  Very interesting problems though, and not sure if I should be using path finding or linear programming (as mentioned).  As an excercise in LP, it was very helpful (LP is one of those things that, when Geoff Whittle does it, seems so straight forward, but upon implementing an LP solution for a problem on my own, I find rather difficult);
  - Day 17, part 2, was similar to day 11, and the classic AoC problem (now that you've simulated this defined system for n cycles, now do it for a bagzillion cycles).  Still haven't found a solution, but I have some good optimisation ideas to remove information we no longer need.  Nothing I have implemented so far is running in any reasonable amount of time, mind...;
  - Day 18&mdash;: part 1 of this (lava cubes) was quite easy for me as Julia handles 3 dimensions very well.  However, part 2 was quite tricky.  I thought for a while and thought I came up with a good solution but my solution had just a few edge cases, putting my answer off about 5.  I figured eventually that there was probably not a "nicer" solution than a flood fill to make a distinction between the outside and inside of the lava;
  - Day 20&mdash;: cool to use doubly-linked lists, which I thought do not have a use in 2022!;
  - Day 22, part 2&mdash;: a cube?  Faces of a cube?!  Julia is good at multidimensional, but I've never had to consider only the _faces_ of a multidimensional structure.  Was very tricky!  Couldn't do it without a bit of arts and crafts...  Still trying to figure out a good, mathematical solution to this; and
  - Day 24 (blizzard) &mdash; another interesting optimisation problem.  Still unfinished, but have realised that blizzard positions are cyclical.  May need further optimisation, but unsure.  Quite a neat problem though.
