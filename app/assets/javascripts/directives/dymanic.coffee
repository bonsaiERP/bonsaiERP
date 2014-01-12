myApp.directive('dynamic', ($compile) ->
  return {
    restrict: 'A',
    replace: true,
    link: ($scope, $elem, $attrs)  ->
      $scope.$watch($attrs.dynamic, (html) ->
        $elem.html(html)
        $compile($elem.contents())($scope)
      )
  }
)
