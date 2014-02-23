# Directive to present the tags
myApp.directive('ngTags', ($compile, $timeout) ->
  restrict: 'A'
  link: ($scope, $elem, $attrs) ->
    $elem.click( ->
      clicked = true
      if not $elem.data('clicked')
        $elem.popover({
          html: true,
          placement: 'bottom',
          trigger: 'manual',
          content: '<div style="width: 200px; height: 100px">Hola</div>'
        })
        $elem.popover('show')
        $elem.data('clicked', true)
        $cont = $elem.data('popover').tip().find('.popover-content')
        $cont.html(contHtml)
        $compile($cont)($scope)
        $timeout(->
          $cont.find('#tag-editor').modal(show: false)
        )
        $scope.$apply()
        # Close when clicked outside popover
        $('body').on('click', (event) ->
          if not(clicked) and $elem.data('clicked') and $(event.target).parents('.popover').length is 0
            $elem.data('popover').tip().hide()
        )
      else
        if $elem.data('popover').tip().css('display') is 'block'
          $elem.data('popover').tip().hide()
        else
          $elem.data('popover').tip().show()

      clicked = false
    )
)

htmlModal = """
<div class="modal hide fade" id="tag-editor">
  <div class="modal-header">
    <button type="button" class="close" ng-click="closeModal()" aria-hidden="true">&times;</button>
    <h4>{{modalTitle}}</h4>
  </div>
  <div class="modal-body">
    <p>
      <input type='text' ng-model='selectedTag.name' placeholder='name' />
      <input type='text' ng-model='selectedTag.bcolor' placeholder='#cfcfcf' />
    </p>
  </div>
  <div class="modal-footer">
    <a href="#" class="btn" ng-click="closeModal()">Close</a>
    <a href="#" class="btn btn-primary" ng-click="save()">Save</a>
  </div>
</div>
"""
contHtml = """
<div ng-controller="TagsController" class='tags-controller'>
  <input type="text" ng-model="search" class="search" placeholder="escriba para buscar" />
  <div class="tags-div">
    <ul class="unstyled tags-list">
      <li ng-repeat="tag in tags | filter:search">
        <input type="checkbox" ng-click='markChecked(tag)'></span>
        <i class="icon-pencil" ng-click="editTag(tag, $index)"></i>
        <span class='tag-item' style='background: {{ tag.bgcolor }};color: {{ color(tag) }}'>{{ tag.label }}</span>
      </li>
    </ul>
  </div>
  <div class='buttons'>
    <button ng-disabled='!tagsAny("checked", true)' class='btn btn-success btn-small'>Filtrar</button>
    <button class='btn btn-small' ng-click='newTag()'><i class="icon-plus-circle"></i> Nueva</button>
    <button ng-disabled='!tagsAny("checked", true)' class='btn btn-primary btn-small'>Applicar</button>
  </div>
  <!--Modal dialog-->
  #{htmlModal}
</div>
"""

myApp.directive('btags', ($compile, $timeout) ->
  restrict: 'E'
  template: """
    <div class="tags-for">
      <span ng-repeat="tag in tags track by $index" class="tag" style="background: {{tag.bgcolor}}; color: {{tag.color}}">
        {{tag.text}}
      </span>
    </div>
  """
  transclude: true
  scope: {}
  link: ($scope, $elem, $attrs) ->
    tags = _($attrs.tagids)
    .map( (id) ->
      tag = bonsai.tags_hash[id.toString()]
      tag.color = _b.idealTextColor(tag.bgcolor)  if tag and tag.bgcolor?
      tag
    ).compact().value()

    if tags.length > 0
      $timeout(->
        $scope.tags = tags
      , 10)
)
