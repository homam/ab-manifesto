{mean, sum, id, map, fold, filter, group-by, obj-to-pairs, head, tail, split-at} = require 'prelude-ls'

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

table-coin-data = (table-selecor , data , {duration = 1000}) ->
	duration = duration / data.length

	$table = d3.select table-selecor
	$tbody = $table.select \tbody
	$tr = $tbody.selectAll \tr .data data
		..enter! .append \tr 
			..append \td .attr \class \n
			..append \td .attr \class \value
	$tr.select \.n .text ((_,i)->i+1)
	$tr.select \.value .text bool-to-headtail
	$tr.style 'opacity', 0 .transition! .duration 10 .delay ((_,i) -> duration*i) .style \opacity, 1 

	summary = 
		Heads: (filter (==0), data).length
		Tails: (filter (==1), data).length
	$summary = $ table-selecor .find '.summary [data-value]' 
		..text ''
	setTimeout ->
		$summary.each ->
			$this = $ this
			$this.text <| summary[$ this .data \value]
	, duration*data.length

table-coin-data '#coin-2-times table.results', (map toss, [1 to 2]), {}
table-coin-data '#coin-10-times table.results', (map toss, [1 to 10]), {}




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


trials = 100
duration = 5000
bins = 10
draw-binomial-n-tries (d3.select '#binomial-n-tries'), (many-random-bins bins, trials),
	on-transition-started: ({key})->
		fake = (heads) -> 
			shuffle <| (map -> 0, [1 to heads]) ++ (map  -> 1, [1 to (bins - heads)])
		table-coin-data '#coin-10-times-20 table.results', (fake key), {duration: 0.2*duration/trials}
	on-transition-ended: (_,i) ->
		if i == (trials - 1)
			$ '#coin-10-times-20 table.results' .css \opacity, 0
	duration: duration

