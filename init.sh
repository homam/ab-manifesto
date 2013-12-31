mkdir public
mkdir public/javascript
mkdir public/javascript/libs
curl http://code.jquery.com/jquery-2.0.3.js > public/javascript/libs/jquery2.js
curl https://raw.github.com/mbostock/d3/master/d3.js > public/javascript/libs/d3.js
curl -L http://preludels.com/prelude-browser.js > public/javascript/libs/prelude-browser.js