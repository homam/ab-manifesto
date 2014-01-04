{mean, sum, id, map, fold, filter, group-by, obj-to-pairs, head, tail, split-at} = require 'prelude-ls'
exports = exports ? this

# binomial trial histogram
# data :: [array of ints] -- to preserve the order of our experiment
draw-binomial-n-tries = ($svg, data, {duration = 1000, width = 600, height = 260, xExtents = null, on-transition-started = noop, on-transition-ended = noop}) ->
	

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
		..domain(if !!xExtents then [xExtents[0] to xExtents[1]] else (map (.key), dgroups) ).rangeRoundBands([0,width], 0.1)
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
		..exit! .remove!
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



exports.draw-binomial-n-tries = draw-binomial-n-tries