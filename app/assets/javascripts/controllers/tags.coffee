myApp.controller 'TagsController', ['$scope', '$http', '$timeout', ($scope, $http, $timeout) ->
  $scope.tags = bonsai.tags

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
  $scope.color = (tag) ->
    _b.idealTextColor tag.bgcolor

  $editor = $('#tag-editor')

  # Edit tags available
  $scope.editTag = (tag, index) ->
    $scope.modalTitle = 'Edit tag'
    $scope.selectedTag = tag
    $scope.currentIndex = index
    $scope.editing = true

    tag = $scope.selectedTag
    $scope.oldTag = angular.copy tag
    $editor.modal('show')
    false

  # Closes the editor modal
  $scope.closeModal = ->
    if $scope.editing
      $scope.tags[$scope.currentIndex] = $scope.oldTag
    else
      $scope.tags.pop()

    $editor.modal('hide')
    false

  # Create a new tag
  $scope.newTag = ->
    $scope.editing = false
    $scope.title = 'New tag'
    $scope.tags.push {color: '#afafaf'}
    $scope.adding = true
    $scope.currentIndex = -1 + $scope.tags.length
    $scope.selectedTag = $scope.tags[$scope.currentIndex]
    $editor.modal('show')
  # Saves the selectedTag
  $scope.save = ->
]
