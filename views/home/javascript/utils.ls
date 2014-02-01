{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, all, flatten, sum, product, zip-all, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty, zip, take-while, break-list, span, head, last} = require 'prelude-ls'
exports = exports || this

random = Math.random
floor = Math.floor
ceil = Math.ceil
round = Math.round
pow = Math.pow
sqrt = Math.sqrt
pi = Math.PI
exp = Math.exp
abs = Math.abs

# sequence  :: ([f], v) -> [f v]
sequence = (fs, v) --> [f v for f in fs]

sequenceA = ([f, ...fs]:list, init, callback) !--> 
	| empty list => callback init
	| otherwise => 
		d <- f!
		sequenceA fs, ([d] ++ init), callback

parseNum = (s) ->
	n = +s
	if isNaN n then 0 else n

shuffle = (arr) ->
	alength = arr.length
	arr `zip-all` (map (-> Math.random!), [0 to alength]) |> sort-by (([v,r]) -> r) |> map ([v,r]) -> v

wait = (time, f) -> setTimeout f, time




toss = -> round random!

# -> [Int]
trial = (number-of-bins) ->
	map toss, [1 to number-of-bins]

# -> [[Int]]
many-trials = (number-of-bins, number-of-trials) -->
	map (-> trial number-of-bins), [1 to number-of-trials]	

random-bin = (number-of-bins) -> 
	sum trial number-of-bins

many-random-bins = (number-of-bins, number-of-trials) -->
	map sum, (many-trials number-of-bins, number-of-trials)
 
bool-to-headtail = (-> if (isHead it) then 'Head' else 'Tail')

isHead = (i) -> i == 1
isTail = (i) -> not isHead i


choose = (n, k) --> 
	product . map (-> (n - (k - it)) / it ) <| [1 to k]

binomial-coefficient = (n) ->
	map (choose n), [0 to n]

binomial-distribution-function = (n, p, k) -->
	(choose n, k) * (pow p, k) * (pow (1 - p), (n - k))

binomial-distribution = (n, p) ->
	map (binomial-distribution-function n, p), [0 to n]

binomial-distribution-confidence = (n, p, left, right) -->
	(binomial-distribution n, p) |> zip [0 to n] |> (map ([i,v]) -> {x:i, y: v}) |> (filter ({x,y}) -> left<=x<=right) |> (map (.y)) >> sum

binomial-distribution-find-confidence-interval = (n, p, confidence) -->
	distribution = (binomial-distribution n, p) |> zip [0 to n] |> (map ([i,v]) -> {x:i, y: v})

	binomial-distribution-find-confidence-interval-of-distribution distribution, confidence
	
# distribution :: [{x,y}]
# -> {left, right, c}
binomial-distribution-find-confidence-interval-of-distribution = (distribution, confidence) -->
	if confidence == 1
		return {left: (head distribution).x, right: (last distribution).x, c: 1}

	confidence-sum = (left, right) ->
		distribution |> (filter ({x,y}) -> left<=x<=right) |> (map (.y)) >> sum

	mu = distribution |> sum . (map ({x,y}) -> x*y)
	rmu = mu |> round
	map (-> [rmu - it, rmu + it]), [0 to rmu] |> (map ([left, right]) -> {left, right, c: (confidence-sum left, right)})
	|> (span ({_, _, c}) -> c <= confidence) |> ([a,b]) -> [(last a), (head b)]
	|> filter (-> !!it)
	|> map (-> v: it, d: abs(confidence - it.c) ) |> (sort-by ({v,d}) -> d) |> (map ({v,d}) -> v) |> head


normal-distribution-function = (mu, sigma, x) -->
	exp( (x - mu)*(x - mu) / ( -2*sigma*sigma) ) / (sigma*sqrt(2*pi))

normal-distribution = (mu, sigma) ->
	map (normal-distribution-function mu, sigma), [0 to mu*2]


binomial-normal-approximation = (n, p) -->
	normal-distribution n*p, sqrt(n*p*(1 - p))


exports.abs = abs
exports.random = random
exports.floor = floor
exports.ceil = ceil
exports.round = round
exports.pow = pow

exports.sequence = sequence
exports.sequenceA = sequenceA
exports.parseNum = parseNum
exports.shuffle = shuffle
exports.wait = wait
exports.noop = $.noop

exports.toss = toss
exports.trial = trial
exports.many-trials = many-trials
exports.random-bin = random-bin
exports.many-random-bins = many-random-bins
exports.bool-to-headtail = bool-to-headtail
exports.isHead = isHead
exports.isTail = isTail

exports.choose = choose
exports.binomial-coefficient = binomial-coefficient
exports.binomial-distribution-function  = binomial-distribution-function
exports.binomial-distribution = binomial-distribution
exports.binomial-distribution-confidence = binomial-distribution-confidence
exports.binomial-distribution-find-confidence-interval = binomial-distribution-find-confidence-interval
exports.binomial-distribution-find-confidence-interval-of-distribution = binomial-distribution-find-confidence-interval-of-distribution

exports.normal-distribution = normal-distribution
exports.binomial-normal-approximation = binomial-normal-approximation