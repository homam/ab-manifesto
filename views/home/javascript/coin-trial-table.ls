{filter} = require 'prelude-ls'
exports = exports || this

# binomial trial table
table-coin-data = ($jqtable , data , {duration = 1000}) !->
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
		Heads: (filter isHead, data).length
		Tails: (filter isTail, data).length
	
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

# many trials binomial trial table
table-coin-data-many = ($jqtable , data , {duration = 1000}) !->
	duration = duration / (data.length+1) / data[0].length

	$table = d3.select $jqtable.get 0
	$tbody = $table.select \tbody
	$toss = $table.select \thead .select \tr.toss 
		..selectAll \th.toss .data [1 to data[0].length+1]
			..enter! .append \th  .attr \class, \toss
			..text (-> if it > data[0].length then 'Count of Heads' else it)

	# wait a lil bit more before rendering the next record
	delayt = -> c = 0; -> (++c)*duration
	delay = delayt!

	$result = $tbody.selectAll \tr.result .data data
		..enter! .append \tr .attr \class, \result .append \th .text (_,i) -> i+1
		..selectAll \td .data (-> it ++ [it])
			..enter! .append \td
			..text ''
			..transition! .delay delay .text( (d,i) -> if (isNaN d) then (filter isHead, d).length else (bool-to-headtail d))



exports.table-coin-data = table-coin-data
exports.table-coin-data-many = table-coin-data-many