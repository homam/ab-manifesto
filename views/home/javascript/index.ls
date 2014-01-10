{mean, sum, id, map, fold, zip, filter, group-by, obj-to-pairs, head, tail, split-at, join} = require 'prelude-ls'
exports = exports ? this


experiment-data-to-histogram = (data) ->
	length = data[0].length
	count = (f, xs) -> (filter f, xs).length
	data = map sum, data
	data = map ((i)-> {count: i, trials: count (==i), data}), [0 to length]




# summary table
# data :: [{count :: Int, trials :: Int}]
table-coin-data-many-sum = ($jqtable, data, {textf = (.trials)}) !->

	$table = d3.select $jqtable.get 0
	$tbody = $table.select \tbody
	$tbody.select \tr.count .selectAll \th.count .data data
		..enter! .append \th .attr \class, \count
		..text (.count)
		..exit! .remove!
	$tbody.select \tr.trials .selectAll \td.trials .data data
		..enter! .append \td .attr \class, \trials
		..text textf
		..exit! .remove!




math-sum = ($jqpre, data) ->
	exp-val = 
		sum . (map ({count, trials}) -> count * trials) <| data
	$jqpre.html <| (join ' + ' <| map (({count, trials}) -> count + "*" + trials), data) + " = " + exp-val


math-sum-chance = ($jqpre, data) ->
	total = 
		sum . (map ({_, trials}) -> trials) <| data
	format = d3.format '%'
	$jqpre.html <| (join ' + ' <| map (({_, trials}) -> format trials/total), data) + " = 100%"


# data: [Int]
graph-coin-data-many =($svg, {data = null, number-of-bins = null, duration = 500}) ->
	data = data ? $svg.data \data
	number-of-bins = number-of-bins ? $svg.data \number-of-bins
	$svg.data \data, data .data \number-of-bins, number-of-bins

	draw-binomial-n-tries (d3.select <| $svg.show! .get 0), data,
		duration: duration
		xExtents: [0, number-of-bins]


_ <- $!


fake = (bins, heads) --> 
	shuffle <| (map -> 0, [1 to heads]) ++ (map  -> 1, [1 to (bins - heads)])

actions =
	'coin-n-items': (n) ->
		$ '#coin-' + n + '-times .experiment' .show!
		table-coin-data ($ '#coin-' + n + '-times table.results'), (map toss, [1 to n]), {}
	'coin-2-times': -> actions['coin-n-items'] 2
	'coin-10-times': -> actions['coin-n-items'] 10, {duration: 500}

	
	'coin-10-times-20-trials-graph-slow': ->
		graph-coin-data-many ($ '#coin-10-times-20-trials svg'), {duration: 2000}


	'coin-10-times-20-trials-all': ->
		
		data = many-trials 10, 20

		# dataset table
		table-coin-data-many ($ '#coin-10-times-20-trials-table table.results' .show!), data, {}

		
		hisogram-data = experiment-data-to-histogram data
		
		# summary table
		table-coin-data-many-sum ($ '#coin-10-times-20-trials-table-sum table.results' .show!), hisogram-data, {}

		# sum is ~100
		math-sum ($ '#coin-10-times-20-trials-table-sum .math-sum'), hisogram-data

		graph-coin-data-many ($ '#coin-10-times-20-trials svg'), {data: (map sum, data), number-of-bins: 10}

		

	'coin-10-times-1000-trials-graph-slow': ->
		graph-coin-data-many ($ '#coin-10-times-1000-trials svg'), {duration: 8000}

	'coin-10-times-1000-trials-all': ->
		number-of-bins = 
			parseInt <| $ '#coin-10-times-1000-trials input[name=number-of-bins]' .val!

		number-of-trials = 1000
		#	parseInt <| $ '#coin-10-times-1000-trials input[name=number-of-trials]' .val!
		
		data = many-trials number-of-bins, number-of-trials

		hisogram-data = experiment-data-to-histogram data
		
		# summary table
		table-coin-data-many-sum ($ '#coin-10-times-1000-trials .table-summary' .show!), hisogram-data, {}
		table-coin-data-many-sum ($ '#coin-10-times-1000-trials .table-summary-chance' .show!), hisogram-data, {textf : -> (it.trials / 1000) |> d3.format '%'}
		math-sum-chance ($ '#coin-10-times-1000-trials .math-sum-chance'), hisogram-data

		graph-coin-data-many ($ '#coin-10-times-1000-trials svg'), {data: (map sum, data), number-of-bins: number-of-bins, duration: 500}





	# data: [Int]
	'coin-n-times-t-trials': ($svg, {data = null, number-of-bins = null, duration = 500}) ->
		data = data ? $svg.data \data
		number-of-bins = number-of-bins ? $svg.data \number-of-bins
		$svg.data \data, data .data \number-of-bins, number-of-bins

		draw-binomial-n-tries (d3.select <| $svg.show! .get 0), data,
			duration: duration
			xExtents: [0, number-of-bins]



	'coin-n-times-t-trials-animate': ($container, bins, trials, duration) ->
		$container.find \.experiment .show!
		$results = $container.find \table.results .css \opacity, 1
		draw-binomial-n-tries (d3.select <| $container.find \svg .get 0), (many-random-bins bins, trials),
			on-transition-started: ({key})->
				table-coin-data $results, (fake key), {duration: 0.2*duration/trials}
			on-transition-ended: (_,i) ->
				if i == (trials - 1)
					$results .css \opacity, 0
			duration: duration

	'coin-10-times-1000-trials': ->
		actions['coin-n-times-t-trials'] ($ '#coin-10-times-1000-trials'), 10, 1000, 20000




$ '#coin-10-times-1000-trials input[name=number-of-bins]' .change ->
	$ '#coin-10-times-1000-trials label[data-value-for=number-of-bins]' .text <| $ this .val! |> parseInt |> (1+)

# $ '#coin-10-times-1000-trials input[name=number-of-trials]' .change ->
# 	$ '#coin-10-times-1000-trials label[data-value-for=number-of-trials]' .text <| $ this .val!




$ 'button[data-action]' .each ->
	$this = $ this 
	act = $this .attr \data-action
	$this.click -> actions[act]!





actions['coin-2-times']!
actions['coin-10-times']!
actions['coin-10-times-20-trials-all']!
table-coin-data-many-sum ($ '#binomial-10-chance' .show!), (binomial-coefficient 10 |> zip [0 to 10] |> map ([i,v]) -> {count:i, trials: v}), {textf : -> (it.trials / 1024) |> d3.format '%'}


exports.actions = actions