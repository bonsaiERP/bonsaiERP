myApp.directive('dynamic', ($compile) ->
  return {
    restrict: 'A',
    replace: true,
    link: (scope, ele, attrs)  ->
      scope.$watch(attrs.dynamic, (html) ->
        ele.html(html)
        $compile(ele.contents())(scope)
      )
  }
)
