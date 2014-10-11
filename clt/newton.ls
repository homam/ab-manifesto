{abs, fix}  = require \prelude-ls

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

	# dfx = derivitive delta, f, x0
	# return newton precision, f, 1 if (abs dfx) < delta
	# x = x0 - ( (f x0) / dfx )
	# return x if (abs <| x - x0) <= precision
	# newton precision, f, x


#console.log <| derivitive 0.001, Math.cos, 0.1
console.log <| newton 0.0001, Math.cos, 0