{mean, sum, id, map, fold, filter, group-by, obj-to-pairs, head, tail, split-at} = require 'prelude-ls'
exports = exports ? this

random = Math.random
floor = Math.floor
ceil = Math.ceil
round = Math.round

toss = -> round random!

random-bin = (number-of-bins) -> 
	sum <| map toss, [1 to number-of-bins]

many-random-bins = (number-of-bins, trials) -->
	map (-> random-bin number-of-bins), [1 to trials]
 
bool-to-headtail = (-> if 0 == it then 'Head' else 'Tail')


# binomial trial table
table-coin-data = ($jqtable , data , {duration = 1000}) ->
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

table-coin-data-many = ($jqtable , data , {duration = 1000}) ->
	console.log data
	duration = duration / (data.length+1)

	$table = d3.select $jqtable.get 0
	$tbody = $table.select \tbody
	$toss = $tbody.select \tr.toss 
		..selectAll \th.toss .data [1 to data[0].length+1]
			..enter! .append \th  .attr \class, \toss
			..text (-> if it > data[0].length then 'Count of Heads' else it)

	$result = $tbody.selectAll \tr.result .data data # [1 to data[0].length]
		..enter! .append \tr .attr \class, \result .append \th .text (_,i) -> i+1
		..selectAll \td .data id
			..enter! .append \td
			..text bool-to-headtail
		..selectAll \th.sum .data (->[it]) 
			..enter! .append \th .attr \class, \sum
			..text (-> (filter (==0), it).length)


	 # .selectAll \td.result .data data
		# ..enter! .append \td .append \span .attr \class, \result
		# ..select \span .text '-'

	return
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







# binomial trial histogram
draw-binomial-n-tries = ($svg, data, {duration = 1000, width = 600, height = 260, on-transition-started = noop, on-transition-ended = noop}) ->
	
	dlength = data.length
	dgroups = group-by id, data |> obj-to-pairs |> map ([key, arr]) -> key: +key, count: arr.length, prob: arr.length / dlength


	margin =
		top: 5
		right: 10
		bottom: 30
		left: 40
	width = width - margin.left - margin.right
	height = height - margin.top - margin.bottom

	 
	$svg.attr \width, (width+margin.left+margin.right) .attr \height, (height+margin.bottom+margin.top)

	
	x = d3.scale.ordinal!
		..domain (map (.key), dgroups) .rangeRoundBands([0,width], 0.1)
	y = d3.scale.linear! .domain [0, d3.max map (.prob), dgroups] .range [height,0]


	# functional, no-side effect way
	# data = fold ((acc,a)-> acc ++ (
	# 	key: a
	# 	x: x a
	# 	y: y <| (filter (-> it.key==a), acc).length / dlength
	# )), [], data

	# efficient way using a dictionary
	next-y = do ->
		xs = {}
		(key) ->
			xs[key] = (xs[key] || 0) + 1

	data = map (-> 
		y-count = next-y it
		y-value = 
			y <| y-count/dlength 
		key: it
		x: x it
		y-count: y-count
		y: y-value
	), data
	

	$vp = $svg.selectAll 'g.vp' .data [data]
	$vpEnter = $vp.enter! .append 'g' .attr 'class', 'vp'
	$vp.attr 'transform', "translate(#{margin.left},#{margin.top} )"

	block-height = 
		ceil <| height / (d3.max . map (.y-count) <| data)
	
	
	duration = duration/data.length

	$block = $vp.selectAll 'rect.block' .data id
		..enter! .append \rect .attr \class, \block 
	$block.attr \width, x.rangeBand! .attr \height, block-height
		..attr \x, (.x) .attr \y -2*(block-height + margin.top)
		#..transition! .delay ((_,i)-> 1.2*(i)*duration) .duration 2*duration .attr \y, -1*(block-height + margin.top)
		..transition! .delay ((_,i)-> (i)*duration) .duration duration .attr \y, (.y) 
			.each \start, on-transition-started .each \end, on-transition-ended


	$vpEnter.append 'g' .attr 'class', 'y axis'
	yAxis = d3.svg.axis! .scale y .orient 'left' .tickFormat ((d3.format ",") . (*dlength)) .tickSize(-width,0,0) .ticks(5)
	$yAxis = $vp.select '.y.axis'
		..transition! .duration 200 .call yAxis

	$vpEnter.append 'g' .attr 'class', 'x axis'
	xAxis = d3.svg.axis! .scale x .orient 'bottom' 
	$xAxis = $svg.select '.x.axis' .attr "transform", "translate(0,#{height})"
		..transition! .duration 200 .call xAxis
		..selectAll 'text' .text id

_ <- $!

fake = (bins, heads) --> 
	shuffle <| (map -> 0, [1 to heads]) ++ (map  -> 1, [1 to (bins - heads)])
actions =
	'coin-n-items': (n) ->
		$ '#coin-' + n + '-times .experiment' .show!
		table-coin-data ($ '#coin-' + n + '-times table.results'), (map toss, [1 to n]), {}
	'coin-2-times': -> actions['coin-n-items'] 2
	'coin-10-times': -> actions['coin-n-items'] 10

	'coin-10-times-20-trials-table': ->
		data = 
			map (fake 10) <| many-random-bins 10, 20
		$results = $ '#coin-10-times-20-trials-table table.results' .show!
		table-coin-data-many $results, data, {}

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