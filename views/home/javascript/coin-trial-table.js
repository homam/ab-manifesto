// Generated by LiveScript 1.2.0
(function(){
  var filter, exports, tableCoinData, tableCoinDataMany;
  filter = require('prelude-ls').filter;
  exports = exports || this;
  tableCoinData = function($jqtable, data, arg$){
    var duration, ref$, $table, $tbody, x$, $toss, y$, $result, summary, $summary;
    duration = (ref$ = arg$.duration) != null ? ref$ : 1000;
    duration = duration / (data.length + 1);
    $table = d3.select($jqtable.get(0));
    $tbody = $table.select('tbody');
    x$ = $toss = $tbody.select('tr.toss').selectAll('th.toss').data(data);
    x$.enter().append('th').attr('class', 'toss');
    x$.text(function(_, i){
      return i + 1;
    });
    y$ = $result = $tbody.select('tr.result').selectAll('td').data(data);
    y$.enter().append('td').append('span');
    y$.select('span').text('-');
    summary = {
      Heads: filter(isHead, data).length,
      Tails: filter(isTail, data).length
    };
    $summary = $jqtable.find('.summary > tr > td').attr('colspan', data.length + 1).find('[data-value]').text('');
    setTimeout(function(){
      return $summary.each(function(){
        var $this;
        $this = $(this);
        return $this.text(summary[$(this).data('value')]);
      });
    }, duration * data.length);
    wait(duration, function(_){
      return $result.select('span').text(boolToHeadtail).style('opacity', 0).transition().duration(10).delay(function(_, i){
        return duration * i;
      }).style('opacity', 1);
    });
  };
  tableCoinDataMany = function($jqtable, data, arg$){
    var duration, ref$, $table, $tbody, x$, $toss, y$, delayt, delay, z$, $result, z1$;
    duration = (ref$ = arg$.duration) != null ? ref$ : 1000;
    duration = duration / (data.length + 1) / data[0].length;
    $table = d3.select($jqtable.get(0));
    $tbody = $table.select('tbody');
    x$ = $toss = $table.select('thead').select('tr.toss');
    y$ = x$.selectAll('th.toss').data((function(){
      var i$, to$, results$ = [];
      for (i$ = 1, to$ = data[0].length + 1; i$ <= to$; ++i$) {
        results$.push(i$);
      }
      return results$;
    }()));
    y$.enter().append('th').attr('class', 'toss');
    y$.text(function(it){
      if (it > data[0].length) {
        return 'Count of Heads';
      } else {
        return it;
      }
    });
    delayt = function(){
      var c;
      c = 0;
      return function(){
        return (++c) * duration;
      };
    };
    delay = delayt();
    z$ = $result = $tbody.selectAll('tr.result').data(data);
    z$.enter().append('tr').attr('class', 'result').append('th').text(function(_, i){
      return i + 1;
    });
    z1$ = z$.selectAll('td').data(function(it){
      return it.concat([it]);
    });
    z1$.enter().append('td');
    z1$.text('');
    z1$.transition().delay(delay).text(function(d, i){
      if (isNaN(d)) {
        return filter(isHead, d).length;
      } else {
        return boolToHeadtail(d);
      }
    });
  };
  exports.tableCoinData = tableCoinData;
  exports.tableCoinDataMany = tableCoinDataMany;
}).call(this);
