myApp.controller 'TagsController', ['$scope', '$http', '$timeout', ($scope, $http, $timeout) ->
  $scope.tags = bonsai.tags
  $scope.editorBtn = 'Crear'
  $scope.tag_name = ''
  $scope.tag_name_errors = ''# 'Solo números, letras o -_'

  # Init
  $scope.colors = ['#FF0000', '#FF9000', '#FFD300', '#77B92D', '#049CDB', '#1253A6', '#4022A7', '#8E129F']
  $scope.tag_bgcolor = '#ffffff'
  $scope.errors = {}
  $scope.saving = true

  # error css @val required to watch the attribute
  $scope.errorCssFor = (val, key) ->
    if $scope.errors[key]? then 'field_with_errors' else ''

  # Marks the checked or unchecks a tag
  $scope.markChecked = (tag) ->
    tag.checked = not tag.checked

  # Checks if any
  $scope.tagsAny = (prop, value) ->
    _.any($scope.tags, (tag) -> tag[prop] is value )

  # text color for a tag
  $scope.color = (color) ->
    _b.idealTextColor color

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
  $scope.markTags() # Initial mark tag

  # Sets the color for tag_bgcolor, can't use tag_bgcolor=color
  $scope.setColor = (color) ->
    $scope.tag_bgcolor = color
    $scope.$colorEditor.minicolors('value', color)
    false

  # Create a new tag
  $scope.newTag = ->
    $scope.errors = []
    $scope.editing = false
    $scope.saving = false
    $scope.tag_bgcolor = '#FF9000'
    $scope.tag_name = ''
    $scope.editorBtn = 'Crear'

    $scope.$colorEditor.minicolors('value', '#FF9000')
    $scope.$editor.dialog('option', 'title', 'Nueva etiqueta')
    $scope.$editor.dialog('open')
    false

  # Edit tags available
  $scope.editTag = (tag, index) ->
    $scope.errors = []
    $scope.currentIndex = index
    $scope.editing = true
    $scope.saving = false
    $scope.tag_id = tag.id
    $scope.tag_name = tag.text
    $scope.tag_bgcolor = tag.bgcolor
    $scope.editorBtn = 'Actualizar'

    $scope.$colorEditor.minicolors('value', tag.bgcolor)
    $scope.$editor.dialog('option', 'title', 'Editar etiqueta')
    $scope.$editor.dialog('open')
    false

  # Saves the selectedTag
  $scope.save = ->
    $scope.saving = true
    $scope.errors = {}
    return  unless $scope.valid()

    $scope.saving = true
    console.log 'Saving', $scope.saving
    if $scope.editing
      $scope.update()
    else
      $scope.create()

  $scope.update = ->
    $http(method: 'PATCH', url: '/tags/' + $scope.tag_id, data: $scope.getFormData())
    .success((data, status) ->
      alert('update')
    )
    .error((data, status)->
    )

  $scope.create = ->
    $http.post('/tags', $scope.getFormData())
    .success(() ->
      console.log status
    )
    .error((data, status)->
      $scope.showSaveError(data)
    )
    .finally(->
      $scope.saving = false
    )

  # Validation
  $scope.valid = ->
    if not $scope.tag_name.match(/^[a-z\u00E0-\u00FC-]+$/i)
      $scope.errors['tag_name'] = 'Ingrese letras, números o "-" sin espacios'
      $('#tag-name-input').notify($scope.errors['tag_name'], {position: 'top left', className: 'error'})
    not _.any($scope.errors)

  # notify
  $scope.showSaveError = (data) ->
    $scope.$editor.parents('div:first')
    .notify('Existió un error al crear', {className: 'error', positon: 'top center'})


  $scope.getFormData = ->
    {tag: {name: $scope.tag_name, bgcolor: $scope.tag_bgcolor}}

]
