import re
ll = [x for x in open('input').read().strip().split('\n\n')]
workflow, parts = ll

def ints(s):
    return list(map(int, re.findall(r'\d+', s)))

parts = [ints(l) for l in parts.split("\n")]
workflow = {l.split("{")[0]: l.split("{")[1][:-1] for l in workflow.split("\n")}

def eval2(part, work):
    w = workflow[work]
    x, m, a, s = part
    for it in w.split(","):
        if it == "R":
            return False
        if it == "A":
            return True
        if ":" not in it:
            return eval2(part, it)
        cond = it.split(":")[0]
        if eval(cond):
            if it.split(":")[1] == "R":
                return False
            if it.split(":")[1] == "A":
                return True
            return eval2(part, it.split(":")[1])
    raise Exception(w)

p1 = 0

for part in parts:
    if eval2(part, 'in'):
        p1 += sum(part)
print(p1)


def both(ch, gt, val, ranges):
    ch = 'xmas'.index(ch)
    ranges2 = []
    for rng in ranges:
        rng = list(rng)
        lo, hi = rng[ch]
        if gt:
            lo = max(lo, val + 1)
        else:
            hi = min(hi, val - 1)
        if lo > hi:
            continue
        rng[ch] = (lo, hi)
        ranges2.append(tuple(rng))
    return ranges2


def acceptance_ranges_outer(work):
    return acceptance_ranges_inner(workflow[work].split(","))

def acceptance_ranges_inner(w):
    it = w[0]
    if it == "R":
        return []
    if it == "A":
        return [((1, 4000), (1, 4000), (1, 4000), (1, 4000))]
    if ":" not in it:
        return acceptance_ranges_outer(it)
    cond = it.split(":")[0]
    gt = ">" in cond
    ch = cond[0]
    val = int(cond[2:])
    val_inverted = val + 1 if gt else val - 1
    if_cond_is_true = both(ch, gt, val, acceptance_ranges_inner([it.split(":")[1]]))
    if_cond_is_false = both(ch, not gt, val_inverted, acceptance_ranges_inner(w[1:]))
    return if_cond_is_true + if_cond_is_false

p2 = 0
for rng in acceptance_ranges_outer('in'):
    v = 1
    for lo, hi in rng:
        v *= hi - lo + 1
    p2 += v
print(p2)
