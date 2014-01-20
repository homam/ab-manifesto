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

	draw-experiment-n-tries (d3.select <| $svg.show! .get 0), data,
		duration: duration
		xExtents: [0, number-of-bins]


_ <- $!


# table and histogram
binomial-n-bins = ($svg, $table, bins = 10, chance = 0.5, options = {}) !->
	data = binomial-distribution bins, chance |> zip [0 to bins] |> map ([i,v]) -> {count:i, prob: v}
	if !!$table
		table-coin-data-many-sum $table.show!, data, textf : (.prob) >> d3.format '%'
	draw-histogram (d3.select $svg.get 0), (map (({count,prob})-> {x:count, y: prob}), data), {
		format: d3.format '%'
	} <<< options




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

		draw-experiment-n-tries (d3.select <| $svg.show! .get 0), data,
			duration: duration
			xExtents: [0, number-of-bins]



	'coin-n-times-t-trials-animate': ($container, bins, trials, duration) ->
		$container.find \.experiment .show!
		$results = $container.find \table.results .css \opacity, 1
		draw-experiment-n-tries (d3.select <| $container.find \svg .get 0), (many-random-bins bins, trials),
			on-transition-started: ({key})->
				table-coin-data $results, (fake key), {duration: 0.2*duration/trials}
			on-transition-ended: (_,i) ->
				if i == (trials - 1)
					$results .css \opacity, 0
			duration: duration

	'coin-10-times-1000-trials': ->
		actions['coin-n-times-t-trials'] ($ '#coin-10-times-1000-trials'), 10, 1000, 20000

	'coin-n-times-binomial': !-> 
		binomial-n-bins ($ '#binomial-n-chance-graph'), null, ($ '.coin-n-times-binomial input[name=number-of-bins]' .val! |> parseInt), 0.5 ,{
			xdomainf: (-> [0 to 200])
			ydomainf: (-> [0, 0.25])
			duration: 100
			width: 800
		}

	'binomial-n-p-chance': !->
		binomial-n-bins ($ '.binomial-n-p-chance svg'), null, ($ '.binomial-n-p-chance input[name=number-of-bins]' .val! |> parseNum), ($ '.binomial-n-p-chance input[name=chance]' .val! |> parseNum), {
			duration: 150
			width: 800
		}

	'binomial-n-p-chance100': !->
		$ '.binomial-n-p-chance input[name=chance]' .val 1 .change!

	'binomial-n-p-chance0': !->
		$ '.binomial-n-p-chance input[name=chance]' .val 0 .change!


	'try-choose-n-k': !->
		n = $ '#try-choose-n-k input[name=n]' .val! |> parseNum
		_ = $ '#try-choose-n-k input[name=k]'
			..attr \max n
			k = ..val! |> parseNum
			if k > n
				..val n
				k := n
		$ '#try-choose-n-k label[data-value-for=k]' .text k

		$ '#try-choose-n-k .result' .html <| choose n, k |> round |> (x) ->
			v = x.toString().split \e+
			if 2 == v.length
				' &asymp; ' + v[0] + '&times;' + '10<sup>' + v[1] + '</sup>'
			else
				' = ' + (d3.format ',') x

	'binomail-ci': !->
		chance = 0.5
		bins = $ '#ci-bins30-number-of-bins' .val! |> parseNum

		$ci-range = $ '#ci-bins30-ci'
		how-many-sigmas = $ci-range .val! |> parseNum

		mu = chance * bins
		sigma = Math.sqrt(bins * chance * (1- chance))

		delta = sigma * how-many-sigmas
		left =  mu - delta |> round
		right = mu + delta |> round

		data = binomial-distribution bins, chance |> zip [0 to bins] |> map ([i,v]) -> {x:i, y: v, className: if left<=i<=right then 'in' else 'out'}

		area = 
			sum . (map (.y)) . (filter ({x,y}) -> left<=x<=right) <| data


		$ci-range.parent! 
			..find 'label[for=ci]' .text <| (d3.format '%') area
			..find 'label[data-value=a]' .text left
			..find 'label[data-value=b]' .text right

		math = MathJax.Hub.getAllJax('ci-bins30-sum')[0]
		if !!math
			MathJax.Hub.Queue(["Text",math,"\\sum_{i=#{left}}^{#{right}} Binomial(#{bins}, i) = #{d3.format("0.2f") (area*100)}\\%"])

		{$vp, $block, x, y} = draw-histogram (d3.select '#ci-bins30'), data, {duration: 300, format: d3.format '%'}

		$block.attr \class, -> 'block ' + it.className



$ 'input[type=range]' .change ->
	$this = $ this 
	$parent = $this.parent!
	$parent.find "label[data-value-for=#{$this.attr 'name'}]" .each ->
		$label = $ this
		eval "var f = function(x) { return #{($label.attr 'data-transform') ? 'x'}; }"
		$label.text <| $this.val! |> parseNum |> f






$ 'button[data-action]' .each ->
	$this = $ this 
	act = $this .attr \data-action
	$this.click -> actions[act]!





actions['coin-2-times']!
actions['coin-10-times']!
actions['coin-10-times-20-trials-all']!
actions['coin-10-times-1000-trials-all']!
binomial-n-bins ($ '#binomial-10-chance-graph'), ($ '#binomial-10-chance-table')
actions['try-choose-n-k']!
actions['coin-n-times-binomial']!
actions['binomial-n-p-chance']!
actions['binomail-ci']!


# double histogram
binomial-double-n-bins = ($svg, [{bins1, chance1}, {bins2, chance2}], options = {}) !->

	data = (chance, bins) -> 
		binomial-distribution bins, chance |> zip [0 to bins] |> map ([i,v]) -> {x:i, y: v}


	draw-double-histogram (d3.select $svg.get 0), [(data chance1, bins1), (data chance2, bins2)], {
		format: d3.format '%'
	} <<< options

binomial-double-n-bins ($ '#binomial-double-histogram'), [{bins1: 625, chance1: 0.3}, {bins2: 637, chance2: 0.25}], {}


exports.actions = actions