prelude = require('prelude-ls')
{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, all, flatten, sum, zip-all, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'
exports = exports || this

random = Math.random

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

exports.sequence = sequence
exports.sequenceA = sequenceA
exports.parseNum = parseNum
exports.shuffle = shuffle
exports.wait = wait
exports.noop = $.noop