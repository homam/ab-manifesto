{sqrt} = require \prelude-ls
{
	find-propability-of-population-mean-in-a-range-for-continuous-variable
	find-confidence-interval-of-population-mean-for-continuous-variable
	find-propability-of-population-mean-in-a-range-for-binomial-variable
	find-confidence-interval-of-population-mean-for-binomial-variable
} = require \./stats

round = (precision, n) -->
	tens = 10**precision
	(Math.round <| n * tens) / tens


prob = find-propability-of-population-mean-in-a-range-for-continuous-variable do
	36 # sample size
	112 # sample mu
	40 # sample sigma
	[100, 124] # lower and upper

console.log "Prob = #prob \n#{0.93 == round 2 prob}\n"



[lower, upper] = find-confidence-interval-of-population-mean-for-continuous-variable do
	36 # sample size
	112 # sampel mu
	40 # sample sigma
	0.9281394664049833 # confidence

console.log "CI = #{[lower, upper]} \n#{100 == round 2 lower and 124 == round 2 upper}\n"



[lower, upper] = find-confidence-interval-of-population-mean-for-binomial-variable do 
	250 # sample size
	142 # successes
	0.99 # confidence
console.log "CI = #{[lower, upper]} \n#{0.49 == round 2 lower and 0.65 == round 2 upper}\n"



prob =  find-propability-of-population-mean-in-a-range-for-binomial-variable do
	250 # sample size
	142 # successes
	[0.4872965881321945, 0.6487034118678054] # bounds

console.log "Prob = #prob \n#{0.99 == round 2 prob}\n"


[lower, upper] = find-confidence-interval-of-population-mean-for-continuous-variable do
	60 # sample size
	7.177 # sample mu
	sqrt 8.691 # sample sigma
	0.95 # confidence

console.log "CI = #{[lower, upper]} \n#{6.43 == round 2 lower and 7.92 == round 2 upper}\n"




[lower, upper] = find-confidence-interval-of-population-mean-for-binomial-variable do 
	31107 # sample size
	1893 # successes
	0.95 # confidence
console.log "Test 16, CI = #{[lower, upper]} \n#{0.49 == round 2 lower and 0.65 == round 2 upper}\n"