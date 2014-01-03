{mean, sum, id, map, fold, filter, group-by, obj-to-pairs, head, tail, split-at} = require 'prelude-ls'
exports = exports ? this


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
		Heads: (filter (==0), data).length
		Tails: (filter (==1), data).length
	
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
			..transition! .delay delay .text( (d,i) -> if (isNaN d) then (filter (==0), d).length else (bool-to-headtail d))

table-coin-data-many-sum = ($jqtable, data) !->
	length = data[0].length
	count = (f, xs) -> (filter f, xs).length
	data = map sum, data
	data = map ((i)-> {count: i, trials: count (==i), data}), [0 to length]


	$table = d3.select $jqtable.get 0
	$tbody = $table.select \tbody
	$tbody.select \tr.count .selectAll \th.count .data data
		..enter! .append \th .attr \class, \count
		..text (.count)
	$tbody.select \tr.trials .selectAll \td.trials .data data
		..enter! .append \td .attr \class, \trials
		..text (.trials)


_ <- $!

fake = (bins, heads) --> 
	shuffle <| (map -> 0, [1 to heads]) ++ (map  -> 1, [1 to (bins - heads)])

actions =
	'coin-n-items': (n) ->
		$ '#coin-' + n + '-times .experiment' .show!
		table-coin-data ($ '#coin-' + n + '-times table.results'), (map toss, [1 to n]), {}
	'coin-2-times': -> actions['coin-n-items'] 2
	'coin-10-times': -> actions['coin-n-items'] 10, {duration: 500}

	'coin-10-times-20-trials-table': ->
		data = 
			map (fake 10) <| many-random-bins 10, 20
		$results = $ '#coin-10-times-20-trials-table table.results' .show!
		table-coin-data-many $results, data, {}
		$results.data \results, data
	'coin-10-times-20-trials-table-sum': ->
		data = $ '#coin-10-times-20-trials-table table.results' .data \results
		$results = $ '#coin-10-times-20-trials-table-sum table.results' .show!
		table-coin-data-many-sum $results, data


	'con-n-times-t-trials': ($container, bins, trials, duration) ->
		$container.find \.experiment .show!
		$results = $container.find \table.results .css \opacity, 1
		draw-binomial-n-tries (d3.select <| $container.find \svg .get 0), (many-random-bins bins, trials),
			on-transition-started: ({key})->
				table-coin-data $results, (fake key), {duration: 0.2*duration/trials}
			on-transition-ended: (_,i) ->
				if i == (trials - 1)
					$results .css \opacity, 0
			duration: duration
	'coin-10-times-20-trials': ->
		actions['con-n-times-t-trials'] ($ '#coin-10-times-20-trials'), 10, 20, 12000

	'coin-10-times-1000-trials': ->
		actions['con-n-times-t-trials'] ($ '#coin-10-times-1000-trials'), 10, 1000, 20000


$ 'button[data-action]' .each ->
	$this = $ this 
	act = $this .attr \data-action
	$this.click -> actions[act]!




exports.actions = actions