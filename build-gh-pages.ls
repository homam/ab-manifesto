cheerio = require \cheerio
fs = require \fs
html = fs.read-file-sync \./views/home/index.ejs, encoding: \utf8
$ = cheerio.load html
$script = $ "script[data-external]"
$script.each ->
	$this = $ this 
	$this.attr \src, $this.attr \data-external


console.log $.html!