{mean, fix, map, filter, sum, sqrt, abs, exp} = require \prelude-ls


statistics = (arr, sample = false) ->
	length = arr.length
	average = mean arr
	sigma = arr |> map (-> (it - average) * (it - average)) |> sum |> (/ (length - if sample then 1 else 0)) |> sqrt
	[length, average, sigma]

random = (lower, upper) -->
	Math.round <| Math.random! * (upper - lower) + lower

make-sample = (how-many, arr) -->
	size = arr.length - 1
	how-many |> 
		fix (next) -> (how-many) ->
			return [] if how-many == 0
			[arr[random 0, size]] ++ next how-many - 1


normal-cdf = (avg, sigma, x) -->
	z = (x - avg) / sqrt 2 * sigma * sigma
	t = 1 / (1 + 0.3275911 * abs z)
	a1 =  0.254829592
	a2 = -0.284496736
	a3 =  1.421413741
	a4 = -1.453152027
	a5 =  1.061405429
	erf = 1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * (exp -z * z)
	sign = if z < 0 then -1 else 1
	(1 / 2) * (1 + sign * erf)


standard-normal-cdf = normal-cdf 0, 1


derivitive = (delta, f, x) -->
	((f <| x + delta) - (f x)) / delta

newton = (precision, f, x0) -->
	df = derivitive precision/10, f

	x0 |>
		fix (next) -> (x0) ->
			dfx = df x0
			return next Math.random! if (abs dfx) < precision
			x = x0 - ( (f x0) / dfx )
			return x if (abs <| x - x0) <= precision
			next x


# generic functions

find-propability-of-population-mean-in-a-range = (sample-mu, samples-means-sigma, [lower, upper]) -->
	standard-upper = (upper - sample-mu) / samples-means-sigma
	standard-lower = (lower - sample-mu) / samples-means-sigma
	(standard-normal-cdf standard-upper) - (standard-normal-cdf standard-lower)

find-confidence-interval-of-population-mean = (sample-mu, samples-means-sigma, confidence) -->
	calculate-confidence = find-propability-of-population-mean-in-a-range sample-mu, samples-means-sigma
	delta = samples-means-sigma/1000
	f = (d) -> 
		interval = [sample-mu - d, sample-mu + d]
		(calculate-confidence interval) - confidence
	d = newton 0.0001, f, 0
	[sample-mu - d, sample-mu + d]


# continuous variable

find-propability-of-population-mean-in-a-range-for-continuous-variable = (sample-size, sample-mu, sample-sigma, [lower, upper]) -->
	find-propability-of-population-mean-in-a-range do 
		sample-mu 
		(sample-sigma / sqrt sample-size)
		[lower, upper]

find-confidence-interval-of-population-mean-for-continuous-variable = (sample-size, sample-mu, sample-sigma, confidence) -->
	find-confidence-interval-of-population-mean do 
		sample-mu
		(sample-sigma / sqrt sample-size)
		confidence


# binomial variable

find-propability-of-population-mean-in-a-range-for-binomial-variable = (sample-size, successes, [lower, upper]) -->
	find-propability-of-population-mean-in-a-range do 
		successes / sample-size
		sqrt(sample-size * (successes/sample-size) * (1 - (successes/sample-size))) /sample-size
		[lower, upper]

find-confidence-interval-of-population-mean-for-binomial-variable = (sample-size, successes, confidence) -->
	find-confidence-interval-of-population-mean do 
		successes / sample-size
		sqrt(sample-size * (successes/sample-size) * (1 - (successes/sample-size))) /sample-size
		confidence


exports = exports or this
exports <<< {
	statistics
	random
	make-sample
	normal-cdf
	standard-normal-cdf
	derivitive
	newton
	
	find-propability-of-population-mean-in-a-range-for-continuous-variable
	probability-of-continuous-mean: find-propability-of-population-mean-in-a-range-for-continuous-variable
	find-confidence-interval-of-population-mean-for-continuous-variable
	ci-of-continuous-mean: find-confidence-interval-of-population-mean-for-continuous-variable

	find-propability-of-population-mean-in-a-range-for-binomial-variable
	probability-of-binomial-mean: find-propability-of-population-mean-in-a-range-for-binomial-variable
	find-confidence-interval-of-population-mean-for-binomial-variable
	ci-of-continuous-mean: find-confidence-interval-of-population-mean-for-binomial-variable
}
