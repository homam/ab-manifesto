prelude = require('prelude-ls')
{id, Obj,map, concat, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique, sort-by, reverse, empty} = require 'prelude-ls'
exports = exports || this


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



exports.sequence = sequence
exports.sequenceA = sequenceA
exports.parseNum = parseNum