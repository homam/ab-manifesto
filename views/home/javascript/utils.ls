prelude = require('prelude-ls')
{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, all, flatten, sum, product, zip-all, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'
exports = exports || this

random = Math.random
floor = Math.floor
ceil = Math.ceil
round = Math.round
pow = Math.pow

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

exports.binomial-distribution = binomial-distribution