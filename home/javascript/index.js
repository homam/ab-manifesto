// Generated by LiveScript 1.2.0
(function(){
  var ref$, mean, sum, id, map, each, fold, zip, filter, find, sortBy, groupBy, objToPairs, head, tail, splitAt, join, zipAll, reverse, exports, experimentDataToHistogram, tableCoinDataManySum, mathSum, mathSumChance, graphCoinDataMany, slice$ = [].slice;
  ref$ = require('prelude-ls'), mean = ref$.mean, sum = ref$.sum, id = ref$.id, map = ref$.map, each = ref$.each, fold = ref$.fold, zip = ref$.zip, filter = ref$.filter, find = ref$.find, sortBy = ref$.sortBy, groupBy = ref$.groupBy, objToPairs = ref$.objToPairs, head = ref$.head, tail = ref$.tail, splitAt = ref$.splitAt, join = ref$.join, zipAll = ref$.zipAll, reverse = ref$.reverse;
  exports = exports != null ? exports : this;
  experimentDataToHistogram = function(data){
    var length, count;
    length = data[0].length;
    count = function(f, xs){
      return filter(f, xs).length;
    };
    data = map(sum, data);
    return data = map(function(i){
      return {
        count: i,
        trials: count((function(it){
          return it === i;
        }), data)
      };
    }, (function(){
      var i$, to$, results$ = [];
      for (i$ = 0, to$ = length; i$ <= to$; ++i$) {
        results$.push(i$);
      }
      return results$;
    }()));
  };
  tableCoinDataManySum = function($jqtable, data, arg$){
    var textf, ref$, $table, $tbody, x$, y$;
    textf = (ref$ = arg$.textf) != null
      ? ref$
      : function(it){
        return it.trials;
      };
    $table = d3.select($jqtable.get(0));
    $tbody = $table.select('tbody');
    x$ = $tbody.select('tr.count').selectAll('th.count').data(data);
    x$.enter().append('th').attr('class', 'count');
    x$.text(function(it){
      return it.count;
    });
    x$.exit().remove();
    y$ = $tbody.select('tr.trials').selectAll('td.trials').data(data);
    y$.enter().append('td').attr('class', 'trials');
    y$.text(textf);
    y$.exit().remove();
  };
  mathSum = function($jqpre, data){
    var expVal;
    expVal = function(){
      return sum(map(function(arg$){
        var count, trials;
        count = arg$.count, trials = arg$.trials;
        return count * trials;
      }).apply(this, arguments));
    }(data);
    return $jqpre.html(join(' + ')(map(function(arg$){
      var count, trials;
      count = arg$.count, trials = arg$.trials;
      return count + "*" + trials;
    }, data)) + " = " + expVal);
  };
  mathSumChance = function($jqpre, data){
    var total, format;
    total = function(){
      return sum(map(function(arg$){
        var _, trials;
        _ = arg$._, trials = arg$.trials;
        return trials;
      }).apply(this, arguments));
    }(data);
    format = d3.format('%');
    return $jqpre.html(join(' + ')(map(function(arg$){
      var _, trials;
      _ = arg$._, trials = arg$.trials;
      return format(trials / total);
    }, data)) + " = 100%");
  };
  graphCoinDataMany = function($svg, arg$){
    var data, ref$, numberOfBins, duration;
    data = (ref$ = arg$.data) != null ? ref$ : null, numberOfBins = (ref$ = arg$.numberOfBins) != null ? ref$ : null, duration = (ref$ = arg$.duration) != null ? ref$ : 500;
    data = data != null
      ? data
      : $svg.data('data');
    numberOfBins = numberOfBins != null
      ? numberOfBins
      : $svg.data('number-of-bins');
    $svg.data('data', data).data('number-of-bins', numberOfBins);
    return drawExperimentNTries(d3.select($svg.show().get(0)), data, {
      duration: duration,
      xExtents: [0, numberOfBins]
    });
  };
  $(function(_){
    var binomialNBins, fake, actions, showInputRangeValue, binomialDoubleNBins, zeroToOneNormal;
    binomialNBins = function($svg, $table, bins, chance, options){
      var data;
      bins == null && (bins = 10);
      chance == null && (chance = 0.5);
      options == null && (options = {});
      data = map(function(arg$){
        var i, v;
        i = arg$[0], v = arg$[1];
        return {
          count: i,
          prob: v
        };
      })(
      zip((function(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = bins; i$ <= to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }()))(
      binomialDistribution(bins, chance)));
      if (!!$table) {
        tableCoinDataManySum($table.show(), data, {
          textf: function(){
            return d3.format('%')(function(it){
              return it.prob;
            }.apply(this, arguments));
          }
        });
      }
      drawHistogram(d3.select($svg.get(0)), map(function(arg$){
        var count, prob;
        count = arg$.count, prob = arg$.prob;
        return {
          x: count,
          y: prob
        };
      }, data), import$({
        format: d3.format('%')
      }, options));
    };
    fake = curry$(function(bins, heads){
      return shuffle(map(function(){
        return 0;
      }, (function(){
        var i$, to$, results$ = [];
        for (i$ = 1, to$ = heads; i$ <= to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }())).concat(map(function(){
        return 1;
      }, (function(){
        var i$, to$, results$ = [];
        for (i$ = 1, to$ = bins - heads; i$ <= to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }()))));
    });
    actions = {
      'coin-n-items': function(n){
        $('#coin-' + n + '-times .experiment').show();
        return tableCoinData($('#coin-' + n + '-times table.results'), map(toss, (function(){
          var i$, to$, results$ = [];
          for (i$ = 1, to$ = n; i$ <= to$; ++i$) {
            results$.push(i$);
          }
          return results$;
        }())), {});
      },
      'coin-2-times': function(){
        return actions['coin-n-items'](2);
      },
      'coin-10-times': function(){
        return actions['coin-n-items'](10, {
          duration: 500
        });
      },
      'coin-10-times-20-trials-graph-slow': function(){
        return graphCoinDataMany($('#coin-10-times-20-trials svg'), {
          duration: 2000
        });
      },
      'coin-10-times-20-trials-all': function(){
        var data, hisogramData;
        data = manyTrials(10, 20);
        tableCoinDataMany($('#coin-10-times-20-trials-table table.results').show(), data, {});
        hisogramData = experimentDataToHistogram(data);
        tableCoinDataManySum($('#coin-10-times-20-trials-table-sum table.results').show(), hisogramData, {});
        mathSum($('#coin-10-times-20-trials-table-sum .math-sum'), hisogramData);
        return graphCoinDataMany($('#coin-10-times-20-trials svg'), {
          data: map(sum, data),
          numberOfBins: 10
        });
      },
      'coin-10-times-1000-trials-graph-slow': function(){
        return graphCoinDataMany($('#coin-10-times-1000-trials svg'), {
          duration: 8000
        });
      },
      'coin-10-times-1000-trials-all': function(){
        var numberOfBins, numberOfTrials, data, hisogramData, fiveHeads;
        numberOfBins = parseInt($('#coin-10-times-1000-trials input[name=number-of-bins]').val());
        numberOfTrials = 1000;
        data = manyTrials(numberOfBins, numberOfTrials);
        hisogramData = experimentDataToHistogram(data);
        tableCoinDataManySum($('#coin-10-times-1000-trials .table-summary').show(), hisogramData, {});
        tableCoinDataManySum($('#coin-10-times-1000-trials .table-summary-chance').show(), hisogramData, {
          textf: function(it){
            return d3.format('%')(
            it.trials / 1000);
          }
        });
        mathSumChance($('#coin-10-times-1000-trials .math-sum-chance'), hisogramData);
        data = graphCoinDataMany($('#coin-10-times-1000-trials svg'), {
          data: map(sum, data),
          numberOfBins: numberOfBins,
          duration: 500
        });
        fiveHeads = function(it){
          return it.count;
        }(
        find(function(it){
          return it.key === 5;
        })(
        data));
        $("[data-value='coin-10-times-1000-trials-5heads']").text(fiveHeads);
        $("[data-value='coin-10-times-1000-trials-5heads-chance']").text(d3.format('%')(fiveHeads / 1000));
        return $("[data-value='coin-10-times-1000-trials-5heads-expval']").text(d3.format('.1f')(fiveHeads / 100));
      },
      'coin-n-times-t-trials': function($svg, arg$){
        var data, ref$, numberOfBins, duration;
        data = (ref$ = arg$.data) != null ? ref$ : null, numberOfBins = (ref$ = arg$.numberOfBins) != null ? ref$ : null, duration = (ref$ = arg$.duration) != null ? ref$ : 500;
        data = data != null
          ? data
          : $svg.data('data');
        numberOfBins = numberOfBins != null
          ? numberOfBins
          : $svg.data('number-of-bins');
        $svg.data('data', data).data('number-of-bins', numberOfBins);
        return drawExperimentNTries(d3.select($svg.show().get(0)), data, {
          duration: duration,
          xExtents: [0, numberOfBins]
        });
      },
      'coin-n-times-t-trials-animate': function($container, bins, trials, duration){
        var $results;
        $container.find('.experiment').show();
        $results = $container.find('table.results').css('opacity', 1);
        return drawExperimentNTries(d3.select($container.find('svg').get(0)), manyRandomBins(bins, trials), {
          onTransitionStarted: function(arg$){
            var key;
            key = arg$.key;
            return tableCoinData($results, fake(key), {
              duration: 0.2 * duration / trials
            });
          },
          onTransitionEnded: function(_, i){
            if (i === trials - 1) {
              return $results.css('opacity', 0);
            }
          },
          duration: duration
        });
      },
      'coin-10-times-1000-trials': function(){
        return actions['coin-n-times-t-trials']($('#coin-10-times-1000-trials'), 10, 1000, 20000);
      },
      'coin-n-times-binomial': function(){
        binomialNBins($('#binomial-n-chance-graph'), null, parseInt(
        $('.coin-n-times-binomial input[name=number-of-bins]').val()), 0.5, {
          xdomainf: function(){
            return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200];
          },
          ydomainf: function(){
            return [0, 0.25];
          },
          duration: 100,
          width: 800
        });
      },
      'binomial-n-p-chance': function(){
        binomialNBins($('.binomial-n-p-chance svg'), null, parseNum(
        $('.binomial-n-p-chance input[name=number-of-bins]').val()), parseNum(
        $('.binomial-n-p-chance input[name=chance]').val()), {
          duration: 150,
          width: 800
        });
      },
      'binomial-n-p-chance100': function(){
        $('.binomial-n-p-chance input[name=chance]').val(1).change();
      },
      'binomial-n-p-chance0': function(){
        $('.binomial-n-p-chance input[name=chance]').val(0).change();
      },
      'try-choose-n-k': function(){
        var n, x$, _, k;
        n = parseNum(
        $('#try-choose-n-k input[name=n]').val());
        x$ = _ = $('#try-choose-n-k input[name=k]');
        x$.attr('max', n);
        k = parseNum(
        x$.val());
        if (k > n) {
          x$.val(n);
          k = n;
        }
        $('#try-choose-n-k label[data-value-for=k]').text(k);
        $('#try-choose-n-k .result').html(function(x){
          var v;
          v = x.toString().split('e+');
          if (2 === v.length) {
            return ' &asymp; ' + v[0] + '&times;' + '10<sup>' + v[1] + '</sup>';
          } else {
            return ' = ' + d3.format(',')(x);
          }
        }(
        round(
        choose(n, k))));
      },
      binomialConfidenceRangeAbs: function($div, mathJaxId){
        var _f, _fix, bins, yeses, chance, data, cumulativeData, a_2, left, right, area, ref$, $vp, $block, x, y, math;
        _f = function(name){
          return $div.find("input[name=" + name + "]");
        };
        _fix = function(name, xl, xr){
          var $e, val;
          $e = _f(name).attr('min', xl).attr('max', xr);
          val = parseNum(
          $e.val());
          if (val > xr) {
            val = xr;
          }
          if (val < xl) {
            val = xl;
          }
          showInputRangeValue(
          $e.val(val));
          return val;
        };
        bins = parseNum(
        _f('bins').val());
        if (_f('yeses').get(0)) {
          yeses = parseNum(_f('yeses').val());
          chance = yeses / bins;
          _f('yeses').attr('max', bins);
          _f('p').val(chance);
        } else {
          chance = parseNum(
          _f('p').val());
        }
        data = map(function(arg$){
          var i, v;
          i = arg$[0], v = arg$[1];
          return {
            x: i,
            y: v
          };
        })(
        zip((function(){
          var i$, to$, results$ = [];
          for (i$ = 0, to$ = bins; i$ <= to$; ++i$) {
            results$.push(i$);
          }
          return results$;
        }()))(
        binomialDistribution(bins, chance)));
        cumulativeData = reverse(
        fold(function(list, arg$){
          var a, rest, x, y;
          a = list[0], rest = slice$.call(list, 1);
          x = arg$.x, y = arg$.y;
          return [{
            x: x,
            y: y + ((a != null ? a.y : void 8) || 0)
          }].concat(list);
        }, [])(
        data));
        if (_f('a_2').get(0)) {
          a_2 = _fix('a_2', 0, Math.round(bins / 2));
          left = chance * bins - a_2;
          if (left < 0) {
            left = 0;
          }
          right = chance * bins + a_2;
          if (right > bins) {
            right = bins;
          }
          if (Math.round(a_2 === Math.round(bins / 2))) {
            left = 0;
            right = bins;
          }
        } else {
          left = _fix('left', 0, bins);
          right = _fix('right', left, bins);
        }
        data = map(function(arg$){
          var x, y;
          x = arg$.x, y = arg$.y;
          return {
            x: x,
            y: y,
            className: left <= x && x <= right ? 'in' : 'out'
          };
        })(
        data);
        area = function(){
          return sum(map(function(it){
            return it.y;
          })(filter(function(arg$){
            var x, y;
            x = arg$.x, y = arg$.y;
            return left <= x && x <= right;
          }).apply(this, arguments)));
        }(data);
        ref$ = drawHistogram(d3.select($div.find('svg').get(0)), data, {
          duration: 300,
          format: d3.format('%'),
          drawPercentageAxis: true
        }), $vp = ref$.$vp, $block = ref$.$block, x = ref$.x, y = ref$.y;
        if (!!mathJaxId) {
          math = MathJax.Hub.getAllJax(mathJaxId)[0];
          if (!!math) {
            MathJax.Hub.Queue(["Text", math, "\\sum_{i=" + Math.round(left) + "}^{" + Math.round(right) + "} Binomial(" + d3.format("0.2f")(chance) + "," + bins + ", i) = " + d3.format("0.2f")(area * 100) + "\\%"]);
          }
        }
        $block.attr('class', function(it){
          return 'block ' + it.className;
        });
        each(function(arg$){
          var name, val;
          name = arg$[0], val = arg$[1];
          return $div.attr("data-" + name, val);
        })(
        [['chance', chance], ['bins', bins], ['left', left], ['right', right]]);
        return {
          bins: bins,
          chance: chance,
          data: data,
          $block: $block
        };
      },
      'binomial-confidence-range': function(){
        actions.binomialConfidenceRangeAbs($('#binomial-confidence-range-histogram'), 'binomial-confidence-range-histogram-math');
      },
      'binomial-polls': function(keepRangeRatios){
        var ref$, bins, chance, data, $block, mean, confidenceData, format, format0, x$, y$;
        keepRangeRatios == null && (keepRangeRatios = true);
        ref$ = actions.binomialConfidenceRangeAbs($('#binomial-polls-histogram'), null), bins = ref$.bins, chance = ref$.chance, data = ref$.data, $block = ref$.$block;
        mean = chance * bins;
        confidenceData = map(function(confidence){
          return {
            confidence: confidence,
            range: binomialDistributionFindConfidenceIntervalOfDistribution(data, confidence)
          };
        }, [1, 0.99, 0.975, 0.95, 0.9, 0.80, 0.7, 0.6, 0.5]);
        format = d3.format("0.1%");
        format0 = d3.format("%");
        x$ = d3.select('#binomial-polls-histogram tbody').selectAll('tr').data(confidenceData);
        y$ = x$.enter().append('tr');
        y$.append('td').attr('class', 'mean');
        y$.append('td').attr('class', 'confidence');
        y$.append('td').attr('class', 'left');
        y$.append('td').attr('class', 'right');
        y$.append('td').attr('class', 'me');
        y$.append('td').attr('class', 'link').append('a').text('Show!').attr('href', 'javascript:void(0)');
        x$.select('td.mean').text(format0(chance));
        x$.select('td.confidence').text(function(){
          return format(function(it){
            return it.confidence;
          }.apply(this, arguments));
        });
        x$.select('td.left').text(function(it){
          return it.range.left + " (" + format(
          it.range.left / bins) + ")";
        });
        x$.select('td.right').text(function(it){
          return it.range.right + " (" + format(
          it.range.right / bins) + ")";
        });
        x$.select('td.me').text(function(it){
          return format(
          (it.range.right - it.range.left) / bins) + "";
        });
        x$.select('td.link a').on('click', function(it){
          $('#binomial-polls-histogram input[name=a_2]').val(Math.round((it.range.right - it.range.left) / 2));
          $('#binomial-polls-histogram input[name=right]').val(it.range.right);
          $('#binomial-polls-histogram input[name=left]').val(it.range.left);
          return actions['binomial-polls'](false);
        });
      },
      'binomail-ci': function(){
        var chance, bins, zoom, $ciRange, howManySigmas, mu, sigma, delta, left, right, data, area, x$, math, ref$, $vp, $block, x, y;
        chance = parseNum(
        $('#ci-bins30-p').val());
        bins = parseNum(
        $('#ci-bins30-number-of-bins').val());
        zoom = $('#ci-bin30-zoom').get(0).checked;
        $ciRange = $('#ci-bins30-ci');
        howManySigmas = parseNum(
        $ciRange.val());
        mu = chance * bins;
        sigma = Math.sqrt(bins * chance * (1 - chance));
        delta = sigma * howManySigmas;
        left = round(
        mu - delta);
        right = round(
        mu + delta);
        data = map(function(arg$){
          var i, v;
          i = arg$[0], v = arg$[1];
          return {
            x: i,
            y: v,
            className: left <= i && i <= right ? 'in' : 'out'
          };
        })(
        zip((function(){
          var i$, to$, results$ = [];
          for (i$ = 0, to$ = bins; i$ <= to$; ++i$) {
            results$.push(i$);
          }
          return results$;
        }()))(
        binomialDistribution(bins, chance)));
        if (zoom) {
          data = filter(function(arg$){
            var x;
            x = arg$.x;
            return x >= mu - 6 * sigma && x <= mu + 6 * sigma;
          })(
          data);
        }
        area = function(){
          return sum(map(function(it){
            return it.y;
          })(filter(function(arg$){
            var x, y;
            x = arg$.x, y = arg$.y;
            return left <= x && x <= right;
          }).apply(this, arguments)));
        }(data);
        x$ = $ciRange.parent();
        x$.find('label[for=ci]').text(d3.format('%')(area));
        x$.find('label[data-value=a]').text(left);
        x$.find('label[data-value=b]').text(right);
        math = MathJax.Hub.getAllJax('ci-bins30-sum')[0];
        if (!!math) {
          MathJax.Hub.Queue(["Text", math, "\\sum_{i=" + left + "}^{" + right + "} Binomial(" + d3.format('0.2f')(chance) + "," + bins + ", i) = " + d3.format("0.2f")(area * 100) + "\\%"]);
        }
        ref$ = drawHistogram(d3.select('#ci-bins30'), sortBy(function(arg$){
          var x;
          x = arg$.x;
          return Math.abs(mu - x);
        })(
        data), {
          mean: mu,
          standardDeviation: sigma,
          duration: 300,
          format: d3.format('%'),
          zoomable: true
        }), $vp = ref$.$vp, $block = ref$.$block, x = ref$.x, y = ref$.y;
        $block.attr('class', function(it){
          return 'block ' + it.className;
        });
      }
    };
    showInputRangeValue = function($this){
      var $parent;
      $parent = $this.parent();
      return $parent.find("label[data-value-for=" + $this.attr('name') + "]").each(function(){
        var $label, ref$;
        $label = $(this);
        eval("var f = function(x) { return " + ((ref$ = $label.attr('data-transform')) != null ? ref$ : 'x') + "; }");
        return $label.text(f(
        parseNum(
        $this.val())));
      });
    };
    $('input[type=range]').change(function(){
      return showInputRangeValue($(this));
    });
    $('button[data-action]').each(function(){
      var $this, act;
      $this = $(this);
      act = $this.attr('data-action');
      return $this.click(function(){
        return actions[act]();
      });
    });
    actions['coin-2-times']();
    actions['coin-10-times']();
    actions['coin-10-times-20-trials-all']();
    actions['coin-10-times-1000-trials-all']();
    binomialNBins($('#binomial-10-chance-graph'), $('#binomial-10-chance-table'));
    actions['try-choose-n-k']();
    actions['coin-n-times-binomial']();
    actions['binomial-n-p-chance']();
    actions['binomail-ci']();
    actions['binomial-confidence-range']();
    actions['binomial-polls']();
    binomialDoubleNBins = function($svg, arg$, options){
      var ref$, bins1, chance1, bins2, chance2, data;
      ref$ = arg$[0], bins1 = ref$.bins1, chance1 = ref$.chance1, ref$ = arg$[1], bins2 = ref$.bins2, chance2 = ref$.chance2;
      options == null && (options = {});
      data = function(chance, bins){
        return map(function(arg$){
          var i, v;
          i = arg$[0], v = arg$[1];
          return {
            x: i,
            y: v
          };
        })(
        zip((function(){
          var i$, to$, results$ = [];
          for (i$ = 0, to$ = bins; i$ <= to$; ++i$) {
            results$.push(i$);
          }
          return results$;
        }()))(
        binomialDistribution(bins, chance)));
      };
      drawDoubleHistogram(d3.select($svg.get(0)), [data(chance1, bins1), data(chance2, bins2)], import$({
        format: d3.format('%')
      }, options));
    };
    binomialDoubleNBins($('#binomial-double-histogram'), [
      {
        bins1: 625,
        chance1: 0.3
      }, {
        bins2: 637,
        chance2: 0.25
      }
    ], {});
    zeroToOneNormal = function($svg, arg$, options){
      var size, ref$, p, data;
      size = (ref$ = arg$.size) != null ? ref$ : 10.0, p = (ref$ = arg$.p) != null ? ref$ : 0.5;
      options == null && (options = {});
      console.log(size);
      data = map(function(arg$){
        var x, y;
        x = arg$[0], y = arg$[1];
        return {
          x: x,
          y: y
        };
      })(
      zipAll((function(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = size; i$ <= to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }()), binomialNormalApproximation(size, p)));
      console.log(binomialNormalApproximation(size, p), size, p);
      return drawPathDiagram(d3.select($svg.get(0)), data, import$({
        format: d3.format('%')
      }, options));
    };
    zeroToOneNormal($('#zero-to-one-normal'), []);
    return exports.actions = actions;
  });
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
  function curry$(f, bound){
    var context,
    _curry = function(args) {
      return f.length > 1 ? function(){
        var params = args ? args.concat() : [];
        context = bound ? context || this : this;
        return params.push.apply(params, arguments) <
            f.length && arguments.length ?
          _curry.call(context, params) : f.apply(context, params);
      } : f;
    };
    return _curry();
  }
}).call(this);
