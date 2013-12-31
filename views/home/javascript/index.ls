prelude = require('prelude-ls')
{id,first,Obj,map, concat, filter, each, find, fold, foldr, fold1, all, any, flatten, sum, group-by, obj-to-pairs, keys, unique, sort-by, reverse, empty} = require 'prelude-ls'

random-bin = (number-of-bins) -->
	Math.ceiling <| Math.random() * number-of-bins

many-random-bins = (number-of-bins, trials) -->
	map number-of-bins, [1 to trials]
 
_ <- $!
