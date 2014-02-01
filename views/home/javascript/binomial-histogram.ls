{mean, sum, id, map, fold, filter, group-by, obj-to-pairs, head, tail, split-at, zip-all, maximum, minimum} = require 'prelude-ls'
exports = exports ? this

# binomial trial histogram
# data :: [array of ints] -- to preserve the order of our experiment
draw-experiment-n-tries = ($svg, data, {duration = 1000, width = 620, height = 260, xExtents = null, on-transition-started = noop, on-transition-ended = noop}) ->
	

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
		..attr \width, x.rangeBand! .attr \height, block-height
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




draw-histogram-axes = ($svg, data, {format = (d3.format ","), xdomainf = (-> map (.x), it), ydomainf = (-> [0, d3.max map (.y), it]),  duration = 1000, width = 600, height = 260, drawPercentageAxis = false}) ->

	console.log drawPercentageAxis

	margin =
		top: 5
		right: 10
		bottom: if drawPercentageAxis then 60 else 30
		left: 40
	width = width - margin.left - margin.right
	height = height - margin.top - margin.bottom

	 
	$svg.attr \width, (width+margin.left+margin.right) .attr \height, (height+margin.bottom+margin.top)

	
	x = d3.scale.ordinal!
		..domain(xdomainf data).rangeBands([0,width], 0.1, 0) # .rangeRoundBands([0,width], 0.1)
	y = d3.scale.linear! .domain (ydomainf data) .range [height,0]
	

	$vp = $svg.selectAll 'g.vp' .data [data]
		..enter! .append 'g' .attr 'class', 'vp'
			..append 'g' .attr 'class', 'y axis'
			..append 'g' .attr 'class', 'x axis'
			..append 'g' .attr 'class', 'xp axis'
		..attr 'transform', "translate(#{margin.left},#{margin.top} )"


	yAxis = d3.svg.axis! .scale y .orient 'left' .tickFormat format .tickSize(-width,0,0) .ticks(5)
	$yAxis = $vp.select '.y.axis'
		..transition! .duration 200 .call yAxis

	bins = x.domain! .length
	xAxis = d3.svg.axis! .scale x .orient 'bottom'
	$xAxis = $svg.select '.x.axis' .attr "transform", "translate(0,#{height})"
		..transition! .duration 200 .call xAxis
		..selectAll 'text' .text ((v,i)->  if i % ceil(bins/20) == 0 then v else '' )
		# ..selectAll 'text' .text ((v,i)->  if i % ceil(bins/20) == 0 then d3.format '0.2p' <| v/bins else '' )

	if drawPercentageAxis
		xpAxis = d3.svg.axis! .scale x .orient 'bottom'
		$xpAxis = $svg.select '.xp.axis' .attr "transform", "translate(0,#{height + 25})"
			..transition! .duration 200 .call xpAxis
			..selectAll 'text' .text ((v,i)->  if i % ceil(bins/20) == 0 then d3.format '0.2p' <| v/bins else '' )

	{$vp, x, y, width, height}

# data :: [{x, y}]
draw-histogram = ($svg, data, {format = (d3.format ","), xdomainf = (-> map (.x), it), ydomainf = (-> [0, d3.max map (.y), it]),  duration = 1000, width = 600, height = 260, drawPercentageAxis = false}) ->

	{$vp, x, y, width, height} = draw-histogram-axes($svg, data, {format, xdomainf, ydomainf,duration,width,height,drawPercentageAxis})

	$block = $vp.selectAll 'rect.block' .data id
		..enter! .append \rect .attr \class, \block 
			..attr \height, 0
			..attr \x, x . (.x) .attr \y, -> y(0)
		..exit! .transition! .duration duration
			..attr \height, 0
			..attr \x, x . (.x) .attr \y, -> y(0)
			..remove!
		..transition! .duration duration
			..attr \width, x.rangeBand! .attr \height, (height -) . y . (.y)
			..attr \x, x . (.x) .attr \y, -> y(it.y)


	if false
		# normal approximation:
		expected-value = data |> sum . (map ({x,y}) -> x*y)
		n = data |> maximum . (map ({x,_}) -> x)
		ldata = [0 to n] `zip-all` (binomial-normal-approximation n, expected-value/n) |> map ([x,y]) -> {x,y}
		
		xl = d3.scale.linear! .domain d3.extent xdomainf data .range [0, width]
		line = d3.svg.line! .x xl . (.x) .y y . (.y) .interpolate \basis
		$vp.selectAll \path.line .data [ldata]
			..enter! .append \path .attr \class, \line 
			..attr \d, line .style \fill, \none .style \stroke, \black .style \stroke-width, 2


	{$vp, $block, x, y}


draw-path-diagram = ($svg, data, {format = (d3.format ","), xdomainf = (-> map (.x), it), ydomainf = (-> [0, d3.max map (.y), it]),  duration = 1000, width = 600, height = 260}) ->

	{$vp, x, y, width, height} = draw-histogram-axes($svg, data, {format, xdomainf, ydomainf,duration,width,height})

	xl = d3.scale.linear! .domain d3.extent xdomainf data .range [0, width]
	line = d3.svg.line! .x xl . (.x) .y y . (.y) .interpolate \basis
	$vp.selectAll \path.line .data [data]
		..enter! .append \path .attr \class, \line 
		..attr \d, line .style \fill, \none .style \stroke, \black .style \stroke-width, 2


	{$vp, x, y}


# data :: [{x, y}]
draw-double-histogram = ($svg, [data1, data2], {format = (d3.format ","), xdomainf = (-> map (.x), it), ydomainf = (-> [0, d3.max map (.y), it]),  duration = 1000, width = 600, height = 260}) ->

	range = ([s, f]) -> [s to f]

	# console.log <| d3.extent map (.x), (data1 ++ data2) |> range |> map (x) -> {x, y: maximum . (map (.y)) . (filter (-> it.x == x)) <| (data1 ++ data2) }
	

	data =
		d3.extent map (.x), (data1 ++ data2) |> range |> map (x) -> {x, y: maximum . (map (.y)) . (filter (-> it.x == x)) <| (data1 ++ data2) }

	data-dff =
		d3.extent map (.x), (data1 ++ data2) |> range |> map (x) -> {x, y: minimum . (map (.y)) . (filter (-> it.x == x)) <| (data1 ++ data2) }

	{$vp, x, y, width, height} = draw-histogram-axes($svg, data, {format, xdomainf, ydomainf,duration,width,height})

	$block = $vp.selectAll \g.data .data [data1, data2, data-dff]
		..enter! .append \g .attr \class, (_,i) -> 'data data-' + i
		..selectAll 'rect.block' .data id
			..enter! .append \rect .attr \class, \block 
				..attr \height, 0
				..attr \x, x . (.x) .attr \y, -> y(0)
			..exit! .transition! .duration duration
				..attr \height, 0
				..attr \x, x . (.x) .attr \y, -> y(0)
				..remove!
			..transition! .duration duration
				..attr \width, x.rangeBand! .attr \height, (height -) . y . (.y)
				..attr \x, x . (.x) .attr \y, -> y(it.y)

	

exports.draw-histogram = draw-histogram
exports.draw-experiment-n-tries = draw-experiment-n-tries
exports.draw-double-histogram = draw-double-histogram

exports.draw-path-diagram = draw-path-diagram