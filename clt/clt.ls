{mean, fix, map, filter, sum, sqrt, abs, exp} = require \prelude-ls
population = require \./population.json

statistics = (arr, sample = false) ->
	length = arr.length
	average = mean arr
	sigma = arr |> map (-> (it - average) * (it - average)) |> mean |> sqrt # sum |> (/ (length - if sample then 1 else 0)) |> sqrt
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
	delta = 0.0001
	df = derivitive delta, f

	x0 |>
		fix (next) -> (x0) ->
			dfx = df x0
			return next Math.random!, if (abs dfx) < delta
			x = x0 - ( (f x0) / dfx )
			return x if (abs <| x - x0) <= precision
			next x

# population = [1 to 5000] |> map (-> random 0, 10)

[_, population-mu, population-sigma] = statistics population


results = [1 to 1000] |> map ->
	sample = make-sample 200, population
	[sample-size, sample-mu, sample-sigma] = statistics sample, true

	samples-means-sigma = sample-sigma / (sqrt sample-size)

	# d = samples-means-sigma * 2
	# normal-cdf-sample = normal-cdf sample-mu, samples-means-sigma
	# [(normal-cdf-sample (sample-mu + d)), (population-mu <= sample-mu + d)] 

	d = 0 # standard deviation after mean
	x = sample-mu + d * samples-means-sigma # true number after mean
	[(standard-normal-cdf d), (population-mu <= x), x] 


console.log \population-mu, population-mu
console.log <| [
	(results |> (map ([p, _]) -> p) |> mean)
	(results |> (map ([_, b]) -> if b then 1 else 0) |> mean)
	(results |> map (.2) |> mean)
]



# ------

find-propability-of-population-mean-in-a-range-for-binomial-variable = (sample-size, sample-mu, sample-sigma, [lower, upper]) -->
	samples-means-sigma = sample-sigma / sample-size
	(normal-cdf sample-mu, samples-means-sigma, upper) - (normal-cdf sample-mu, samples-means-sigma, lower)

find-propability-of-population-mean-in-a-range = (sample-size, sample-mu, sample-sigma, [lower, upper]) -->
	samples-means-sigma = sample-sigma / sqrt sample-size
	(normal-cdf sample-mu, samples-means-sigma, upper) - (normal-cdf sample-mu, samples-means-sigma, lower)

find-confidence-interval-of-population-mean-f = (reverse-f, sample-size, sample-mu, sample-sigma, confidence) -->
	calculate-confidence = reverse-f sample-size, sample-mu, sample-sigma
	delta = sample-sigma / 10000
	0 |> 
		fix (next) -> (d) ->
			interval = [sample-mu - d, sample-mu + d]
			return interval if (calculate-confidence interval) >= confidence
			next d + delta


find-confidence-interval-of-population-mean = find-confidence-interval-of-population-mean-f find-propability-of-population-mean-in-a-range
find-confidence-interval-of-population-mean-for-binomial-variable = find-confidence-interval-of-population-mean-f find-propability-of-population-mean-in-a-range-for-binomial-variable



console.log <| find-propability-of-population-mean-in-a-range 36, 112, 40, [100, 124]

console.log <| find-confidence-interval-of-population-mean 36, 112, 40, 0.9281394664049833

console.log <| find-confidence-interval-of-population-mean-for-binomial-variable 250, (142/250), (sqrt <| 250 * (142/250) * (1 - (142/250)) ), 0.99

console.log <| find-confidence-interval-of-population-mean 60, 7.177, (sqrt 8.691), 0.95


console.log \---- 
# ---- 

# generic functions

find-propability-of-population-mean-in-a-range = (sample-mu, samples-means-sigma, [lower, upper]) -->
	standard-upper = (upper - sample-mu) / samples-means-sigma
	standard-lower = (lower - sample-mu) / samples-means-sigma
	(standard-normal-cdf standard-upper) - (standard-normal-cdf standard-lower)

find-confidence-interval-of-population-mean = (sample-mu, samples-means-sigma, confidence) -->
	calculate-confidence = find-propability-of-population-mean-in-a-range sample-mu, samples-means-sigma
	delta = samples-means-sigma/1000
	interval = null
	f = (d) -> 
		interval := [sample-mu - d, sample-mu + d]
		(calculate-confidence interval) - confidence
	newton 0.001, f, 0
	return interval
	# 0 |> 
	# 	fix (next) -> (d) ->
	# 		interval = [sample-mu - d, sample-mu + d]
	# 		return interval if (calculate-confidence interval) >= confidence
	# 		next d + delta


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



console.log <| find-propability-of-population-mean-in-a-range-for-continuous-variable do
	36 # sample size
	112 # sample mu
	40 # sample sigma
	[100, 124] # lower and upper

console.log <| find-confidence-interval-of-population-mean-for-continuous-variable do
	36 # sample size
	112 # sampel mu
	40 # sample sigma
	0.9281394664049833 # confidence

console.log <| find-confidence-interval-of-population-mean-for-binomial-variable do 
	250 # sample size
	142 # successes
	0.99 # confidence

console.log <| find-propability-of-population-mean-in-a-range-for-binomial-variable do
	250 # sample size
	142 # successes
	[0.4872965881321945, 0.6487034118678054] # bounds

console.log <| find-confidence-interval-of-population-mean-for-continuous-variable do
	60 # sample size
	7.177 # sample mu
	sqrt 8.691 # sample sigma
	0.95 # confidence



# -----


# find-confidence-interval-of-population-mean-for-binomial-variable = (sample-size, successes) ->


# sample-size = 36
# sample-mu = 112
# sample-sigma = 40
# question = ({population-mu}) -> (abs (population-mu - sample-mu)) <= 12


# samples-means-sigma = sample-sigma / sqrt sample-size
# console.log <| (standard-normal-cdf 12/samples-means-sigma) - (standard-normal-cdf -12/samples-means-sigma)
# console.log <| (normal-cdf sample-mu, samples-means-sigma, sample-mu + 12) - (normal-cdf sample-mu, samples-means-sigma, sample-mu - 12)

# JSON.stringify(Array.prototype.slice.call($$("tbody td"), null).map(function(t) { return parseInt(t.textContent) }).filter(function(t) { return !isNaN(t)}))

# ;
# WITH T AS (
# SELECT CAST((SELECT COUNT(*) FROM Billings B WITH (NOLOCK) WHERE B.SubscriberId = S.SubscriberId AND Billed_date < DATEADD(d, 30, S.Sub_Created)) AS FLOAT) as Billings FROM Subscribers S WITH (NOLOCK) 
# WHERE S.OC = 12
# AND S.Sub_Created between '2014-08-20' and '2014-08-21'
# ),
# G as (
#  SELECT TOP 100 Billings as Billings FROM T ORDER BY newid() DESC
# )

# -- SELECT  
# --  AVG(Billings) as Mean, 
# --  STDEV(Billings) as Sigma,
# --  (SELECT AVG(Billings) FROM T) as TrueMu
# -- FROM G

# SELECT * FROM T
