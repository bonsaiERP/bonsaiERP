myApp.directive('tagGroupSelect', ['$window', ($window) ->
  restrict: 'E'
  transclude: true
  link: ($scope, $element, $attrs) ->
    tags_hash = $window.bonsai.tags_hash
    $scope.selectedTags = []

    findTagGroup = (id) ->
      $window.tag_groups.filter( (tg) ->
        tg.id is id
      )[0]

    selectTags = (tag_ids) ->
      $scope.selectedTags = []

      tag_ids.forEach (id) ->
        if tags_hash[id]
          $scope.selectedTags.push tags_hash[id]

    changeTags = (tg_id) ->
      tagGroup = findTagGroup(tg_id)
      selectTags( tagGroup.tag_ids )

    $sel = $element.find('select').on('change', (val) ->
      val = $sel.val()

      if val isnt ''
        val = parseInt( val )
        changeTags(val)
      else
        $scope.selectedTags = []

      $scope.$apply()
    )

    if $sel.val() isnt ''
      val = parseInt( $sel.val() )
      changeTags(val)


    $scope.color = Plugins.Tag.textColor

  #
  template: """
  <span ng-transclude></span>
  <div class="tags-for">
    <span ng-repeat="tag in selectedTags" class="tag" style="background:{{ tag.bgcolor }};color: {{ color(tag.bgcolor) }}">
      {{ tag.name }}
    </span>
  </div>
  """
])
