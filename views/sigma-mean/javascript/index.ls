{id, sqrt, div, abs, mean, sum, id, map, foldl, concat-map, minimum, maximum, each, fold, zip, zip-with, filter, find, sort-by, group-by, obj-to-pairs, head, tail, split-at, join, zip-all, reverse} = require 'prelude-ls'

window.actions = {}


binomial-distribution-list = (n, p) ->
	mu = n * p
	sigma = sqrt n * p * (1 - p)
	distribution = [0 to n] `zip` (binomial-distribution n, p)
		|> map ([x, y]) -> x: x, y: y
		|> sort-by ({x}) -> abs mu - x


draw = ($svg, n, p, distribution) ->
	mu = n * p
	sigma = sqrt n * p * (1 - p)


	width = $svg.node!.offset-width
	height = $svg.node!.offset-height

	margin =
		top: 5
		right: 10
		bottom: 50
		left: 40
	width = width - margin.left - margin.right
	height = height - margin.top - margin.bottom
	format = d3.format ","




	xs = distribution |> map (.x)

	ys = [0, d3.max map (.y), distribution]


	min-xs = minimum xs
	max-xs = maximum xs

	[f-range-xs, range-xs] = do ->
		f = (x) -> (width/(max-xs - min-xs)) * (x - min-xs)
		[f, [f x for x in xs]]


	# d: sigma dinstance to the mean; v: real value of the point
	standard-xs = [{d: 0, v: mu}] ++ do -> 
		partitions = 5 *  p * n / sigma
		[1 to partitions] 
			|> concat-map (i) -> [{d: -1 * i, v: mu - i * sigma}, {d: i, v: mu + i * sigma}]
			|> filter ({v}) -> v >= min-xs and v <= max-xs


	range-standard-xs = standard-xs |> map ((.v) >> f-range-xs)


	x = d3.scale.ordinal!.domain xs .range range-xs
	x.range-band = -> width/range-xs.length

	y = d3.scale.linear! .domain ys .range [height,0]


	$vp = $svg.select-all \g.vp .data [distribution]
		..enter! .append \g .attr \class, \vp
			..append \g .attr \class, 'y axis'
			# ..append \g .attr \class, 'x axis'
			# ..append \g .attr \class, 'xp axis'
		..attr \transform, "translate(#{margin.left},#{margin.top} )"


	duration = 200

	extent = width / standard-xs.length
	standard-xs = do -> head <| standard-xs |> foldl do 
		([acc, [last, is-next]], a) ->
			current = (abs <| (f-range-xs a.v) - (f-range-xs standard-xs.0.v)) `div` 40
			a.show-label = (current > last) or (is-next and (a.d == 0 or (a.d * acc[*-1]?.d) < 0)) # is-next
			[acc ++ [a], [current, (current > last)]]
		[[], [0, true]]

	$vp.select-all \g.sdevtick .data standard-xs
		..enter! .append \g .attr \class, \sdevtick 
			..attr \transform, -> "translate(#{2 * (f-range-xs it.v) - width},#{height + 50 - margin.bottom})"
			..append \rect 
				..attr \width, 2
				..attr \height, 10
				..attr \y, 0
			..append \text .attr \class, \sigma
				..attr \text-anchor, \middle
				..attr \y, 30
			..append \text .attr \class, \value
				..attr \text-anchor, \middle
				..attr \y, 50
		..select \.sigma
			..text ({d, show-label}) -> if not show-label then "" else if 0 == d then "0" else if (abs d) > 1 then "#{d} σ" else if d < 0 then "- σ" else "σ"
		..select \.value
			..text ({d, show-label}) -> if not show-label then "" else sigma * d + mu |> round
		..exit!.transition duration 
			..attr \transform, -> "translate(#{2 * (f-range-xs it.v) - width},#{height + 50 - margin.bottom} )"
			..remove!
		..transition! .duration duration 
			..attr \transform, -> "translate(#{f-range-xs it.v},#{height + 50 - margin.bottom})"


	y-axis = d3.svg.axis! .scale y .orient 'left' .tick-format format .tick-size(-width,0,0) .ticks(5)
	$y-axis = $vp.select '.y.axis'
		..transition! .duration duration .call y-axis


	$block = $vp.select-all \rect.block .data id
		..enter! .append \rect .attr \class, \block 
			..attr \height, 0
			..attr \x, x . (.x) .attr \y, -> y 0
		..exit! .transition! .duration duration
			..attr \height, 0
			..attr \x, x . (.x) .attr \y, -> y 0
			..remove!
		..transition! .duration duration
			..attr \width, x.rangeBand! .attr \height, (height -) . y . (.y)
			..attr \x, x . (.x) .attr \y, y . (.y)


draw (d3.select \svg), 500, 0.4, (binomial-distribution-list 500, 0.4)

actions['draw-binomial-distribution-with-sigmas'] = ($parent) ->
	n = $parent.find '[name=n]' .val! |> parse-int
	p = $parent.find '[name=p]' .val! |> parse-float
	zoom = $parent.find '[name=zoom]' .get 0 .checked

	mu = n * p
	sigma = sqrt n * p * (1 - p)

	distribution = (binomial-distribution-list n, p) |> if not zoom then id else filter ({x}) -> x >= (mu - 6 * sigma) and x <= (mu + 6 * sigma)
	draw (d3.select <| $parent.find \svg .get 0), n, p, distribution


# set-timeout do
# 	-> 
# 		draw n, p, (distribution |> filter ({x}) -> x >= (mu - 6 * sigma) and x <= (mu + 6 * sigma))
# 	2000

# set-timeout do
# 	-> 
# 		draw n, p, (distribution |> filter ({x}) -> x >= (mu - 12 * sigma) and x <= (mu + 12 * sigma))
# 	400000