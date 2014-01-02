myApp.directive 'ngNewElement', [ ->
  restrict: 'A',
  link: ($scope, $elem, attr) ->
    $elem.on('ajax-call', (event, resp) ->
      console.log 'A', arguments
    )
]
