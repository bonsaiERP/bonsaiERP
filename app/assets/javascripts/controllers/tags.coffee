myApp.controller 'TagsController', ['$scope', '$http', '$timeout', ($scope, $http, $timeout) ->
  $scope.tags = bonsai.tags

  $scope.colors = ['#FF0000', '#FF9000', '#FFD300', '#77B92D', '#049CDB', '#1253A6', '#4022A7', '#8E129F']

  $scope.modalTitle = 'New tag'
  $scope.selectedTag = {}
  # Displays the correct icon for a tag to show checked or uncheked
  $scope.checkedTagCss = (tag) ->
    if tag.checked is true
      'icon-check-square-o'
    else
      'icon-square-o'

  # Marks the checked or unchecks a tag
  $scope.markChecked = (tag) ->
    tag.checked = not tag.checked

  # Checks if any
  $scope.tagsAny = (prop, value) ->
    _.any($scope.tags, (tag) -> tag[prop] is value )

  # text color for a tag
  $scope.color = (color) ->
    _b.idealTextColor color


  # Edit tags available
  $scope.editTag = (tag, index) ->
    $scope.currentIndex = index
    $scope.editing = true
    $scope.tag_name = tag.text
    $scope.tag_bgcolor = tag.bgcolor

    $scope.$editor.dialog('option', 'title', 'Editar etiqueta')
    $scope.$editor.dialog('open')
    false

  # Functions to filter tags
  $scope.filter = ->
    window.location = [$scope.url, $scope.createTagFilterParams()].join("?")

  $scope.selectedTags = ->
    _.select($scope.tags, (tag) -> tag.checked )

  $scope.createTagFilterParams = ->
    _.map($scope.selectedTags(), (tag) -> "tag_ids[]=#{tag.id}" ).join("&")
  # End of functions to filter tags

  # Closes the editor modal
  $scope.closeModal = ->
    if $scope.editing
      $scope.tags[$scope.currentIndex] = $scope.oldTag
    else
      $scope.tags.pop()

    $scope.editor.modal('hide')
    false

  # Marks the selected tags
  $scope.markTags = ->
    _.each($scope.tags, (tag) ->
      tag.checked = true  if _.include($scope.tagIds, tag.id)
    )

  $scope.markTags()

  $scope.setColor = (color) -> $scope.tag_bgcolor = color

  # Create a new tag
  $scope.newTag = ->
    $scope.editing = false
    $scope.title = 'New tag'
    $scope.tags.push {color: '#afafaf'}
    $scope.adding = true
    $scope.currentIndex = -1 + $scope.tags.length
    $scope.selectedTag = $scope.tags[$scope.currentIndex]
    $scope.$editor.dialog('option', 'title', 'Nueva etiqueta')
    $scope.$editor.dialog('open')
  # Saves the selectedTag
  $scope.save = ->
]
