{mean, sum, id, map, fold, filter, group-by, obj-to-pairs, head, tail, split-at, join} = require 'prelude-ls'
exports = exports ? this


experiment-data-to-histogram = (data) ->
	length = data[0].length
	count = (f, xs) -> (filter f, xs).length
	data = map sum, data
	data = map ((i)-> {count: i, trials: count (==i), data}), [0 to length]


# binomial trial table
table-coin-data = ($jqtable , data , {duration = 1000}) !->
	duration = duration / (data.length+1)

	$table = d3.select $jqtable.get 0
	$tbody = $table.select \tbody
	$toss = $tbody.select \tr.toss .selectAll \th.toss .data data
		..enter! .append \th  .attr \class, \toss
		..text ((_,i) -> i+1)
	$result = $tbody.select \tr.result .selectAll \td .data data
		..enter! .append \td .append \span
		..select \span .text '-'

	summary = 
		Heads: (filter isHead, data).length
		Tails: (filter isTail, data).length
	
	$summary = $jqtable.find '.summary > tr > td' 
		.attr \colspan data.length+1
		.find '[data-value]' .text '' 
	setTimeout ->
		$summary.each ->
			$this = $ this
			$this.text <| summary[$ this .data \value]
	, duration*(data.length)

	_ <- wait duration
	$result.select \span .text bool-to-headtail
			.style 'opacity', 0 .transition! .duration 10 .delay ((_,i) -> duration*i) .style \opacity, 1 

table-coin-data-many = ($jqtable , data , {duration = 1000}) !->
	duration = duration / (data.length+1) / data[0].length

	$table = d3.select $jqtable.get 0
	$tbody = $table.select \tbody
	$toss = $tbody.select \tr.toss 
		..selectAll \th.toss .data [1 to data[0].length+1]
			..enter! .append \th  .attr \class, \toss
			..text (-> if it > data[0].length then 'Count of Heads' else it)

	# wait a lil bit more before rendering the next record
	delayt = -> c = 0; -> (++c)*duration
	delay = delayt!

	$result = $tbody.selectAll \tr.result .data data
		..enter! .append \tr .attr \class, \result .append \th .text (_,i) -> i+1
		..selectAll \td .data (-> it ++ [it])
			..enter! .append \td
			..text ''
			..transition! .delay delay .text( (d,i) -> if (isNaN d) then (filter isHead, d).length else (bool-to-headtail d))

# data :: [{count :: Int, trials :: Int}]
table-coin-data-many-sum = ($jqtable, data) !->

	$table = d3.select $jqtable.get 0
	$tbody = $table.select \tbody
	$tbody.select \tr.count .selectAll \th.count .data data
		..enter! .append \th .attr \class, \count
		..text (.count)
	$tbody.select \tr.trials .selectAll \td.trials .data data
		..enter! .append \td .attr \class, \trials
		..text (.trials)


math-sum = ($jqpre, data) ->
	exp-val = 
		sum . (map ({count, trials}) -> count * trials) <| data
	$jqpre.html <| (join ' + ' <| map (({count, trials}) -> count + "*" + trials), data) + " = " + exp-val



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
		table-coin-data-many-sum ($ '#coin-10-times-20-trials-table-sum table.results' .show!), hisogram-data

		# sum is ~100
		math-sum ($ '#coin-10-times-20-trials-table-sum .math-sum'), hisogram-data

		graph-coin-data-many ($ '#coin-10-times-20-trials svg'), {data: (map sum, data), number-of-bins: 10}

		


	'coin-10-times-1000-trials-all': ->
		0





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


$ 'button[data-action]' .each ->
	$this = $ this 
	act = $this .attr \data-action
	$this.click -> actions[act]!



actions['coin-2-times']!
actions['coin-10-times']!
actions['coin-10-times-20-trials-all']!

exports.actions = actions