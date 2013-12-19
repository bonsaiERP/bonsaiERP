angular.module('numberFilters', [])
.filter('decimal', ->
  (input, dec = 2) -> _b.ntc input, dec
)
.filter('currencyLabel', ->
  (input) ->
    _b.currencyLabel input
)
