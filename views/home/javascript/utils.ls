prelude = require('prelude-ls')
{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, all, flatten, sum, zip-all, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'
exports = exports || this

random = Math.random
floor = Math.floor
ceil = Math.ceil
round = Math.round

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

random-bin = (number-of-bins) -> 
	sum <| map toss, [1 to number-of-bins]

many-random-bins = (number-of-bins, trials) -->
	map (-> random-bin number-of-bins), [1 to trials]
 
bool-to-headtail = (-> if 0 == it then 'Head' else 'Tail')



exports.random = random
exports.floor = floor
exports.ceil = ceil
exports.round = round

exports.sequence = sequence
exports.sequenceA = sequenceA
exports.parseNum = parseNum
exports.shuffle = shuffle
exports.wait = wait
exports.noop = $.noop

exports.toss = toss
exports.random-bin = random-bin
exports.many-random-bins = many-random-bins
exports.bool-to-headtail = bool-to-headtail