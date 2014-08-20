# Main controller that applies edits and creates tags
TagsController = ($scope, $element, $http, $timeout, $window, $rootScope) ->
  $scope.tags = $window.bonsai.tags
  $scope.editorBtn = 'Crear'
  $scope.tag_name = ''

  # Init
  $scope.colors = ['#FF0000', '#FF9000', '#FFD300', '#77B92D', '#049CDB', '#1253A6', '#4022A7', '#8E129F']
  $scope.tag_bgcolor = '#ffffff'
  $scope.errors = {}

  $scope.disableApply = ->
    $('input.row-check:checked').length is 0

  # Detect changes on tags
  $('body').on('click', 'input.row-check', ->
    $scope.disableApply()
    $scope.$apply()
    true
  )

  # error css @val required to watch the attribute
  $scope.errorCssFor = (val, key) ->
    if $scope.errors[key]? then 'field_with_errors' else ''

  # Marks the checked or unchecks a tag
  $scope.markChecked = (tag) ->
    tag.checked = not tag.checked

  # Checks if any
  $scope.tagsAny = (prop, value) ->
    _.any($scope.tags, (tag) -> tag[prop] is value )

  # text color for a tag, this is a function
  $scope.color = Plugins.Tag.textColor

  # Functions to filter tags
  $scope.filter = ->
    $window.location = [$scope.url, $scope.createTagFilterParams()].join("?")

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

  # Apply selected tags of the selected rows
  $scope.applyTags = ->
    $but = $scope.editor.find('.apply-tags')
    $but.prop('disabled', true)

    ids = _.map($('input.row-check:checked'), (el) -> el.id )
    tag_ids = _($scope.tags).select((tag) -> tag.checked)
    .map('id').value()
    data = { tag_ids: tag_ids, ids: ids, model: $scope.model }

    $http(method: 'PATCH', url: '/tags/update_models', data: data)
    .success((data, status) ->
      $scope.setListTags(ids, tag_ids)
      $element.notify('Se aplico las etiquetas correctamente', {position: 'top', className: 'success'})
    )
    .error((data, status)->
      $scope.showSaveErrors(data, status)
      $element.notify('Existio un error al aplicar las etiquetas', {position: 'top', className: 'error'})
    )
    .finally(->
      $but.prop('disabled', true)
    )

  # Updates the tags for each item on a list
  $scope.setListTags = (ids, tag_ids) ->
    tags = Plugins.Tag.getTagsById(tag_ids)
    _(ids).each (id) ->
      sel = "tagsfor[id='#{id}']"
      scope = $(sel).isolateScope()
      scope.tags = tags
      #scope.$apply()


  ########################################
  # Operations to create edit tags
  # Saves the selectedTag

  # Create a new tag
  $scope.newTag = ->
    $scope.errors = []
    $scope.editing = false
    $scope.tag_bgcolor = '#FF9000'
    $scope.tag_name = ''
    $scope.editorBtn = 'Crear'

    $scope.$colorEditor.minicolors('value', '#FF9000')
    $scope.editor.dialog('option', 'title', 'Nueva etiqueta')
    $scope.editor.dialog('open')
    false

  # Edit tags available
  $scope.editTag = (tag, index) ->
    $scope.errors = []
    $scope.currentIndex = index
    $scope.editing = true
    # ng-disabled directive not working
    $scope.editor.find('button').prop('disabled', false)
    $scope.tag_id = tag.id
    $scope.tag_name = tag.name
    $scope.tag_bgcolor = tag.bgcolor
    $scope.editorBtn = 'Actualizar'

    $scope.$colorEditor.minicolors('value', tag.bgcolor)
    $scope.editor.dialog('option', 'title', 'Editar etiqueta')
    $scope.editor.dialog('open')
    false

  $scope.save = () ->
    $scope.errors = {}
    return  unless $scope.valid()

    $scope.editor.find('button').prop('disabled', true)

    if $scope.editing
      $scope.update()
    else
      $scope.create()

  # Updates a tag
  $scope.update = ->
    $http(method: 'PATCH', url: '/tags/' + $scope.tag_id, data: $scope.getFormData())
    .success((data, status) ->
      color = Plugins.Tag.textColor(data.bgcolor)
      tag = { name: data.name, bgcolor: data.bgcolor, id: data.id, color: color }

      $scope.tags[$scope.currentIndex] = tag
      $scope.editor.dialog('close')

      # Set global tags_hash variable
      $window.bonsai.tags_hash[data.id] = { name: data.name, label: data.name, bgcolor: data.bgcolor, id: data.id }
      $window.bonsai.tags.push { name: data.name, label: data.name, bgcolor: data.bgcolor, id: data.id }
      # Update all related
      sel = ".tag#{data.id}"
      $(sel).text(data.name).css({background: data.bgcolor, color: color})
    )
    .error((data, status)->
      $scope.showSaveErrors(data, status)
    )
    .finally(->
      $scope.editor.find('button').prop('disabled', false)
    )

  # Creates new tag
  tagsDiv = $('.tags-div')
  $scope.create = ->
    $http.post('/tags', $scope.getFormData())
    .success((data, status) ->
      $scope.tags.push { name: data.name, bgcolor: data.bgcolor, id: data.id }
      # Set global tags_hash variable
      tag = { name: data.name, label: data.name, bgcolor: data.bgcolor, id: data.id }
      $window.bonsai.tags_hash[data.id] = tag
      $rootScope.$emit('newHash', tag)

      $timeout(->
        tagsDiv.scrollTo(tagsDiv.height() + 400)
      , 30)
      $scope.editor.dialog('close')
    )
    .error((data, status)->
      $scope.showSaveErrors(data, status)
    )
    .finally(->
      $scope.editor.find('button').prop('disabled', false)
    )

  # Validation
  $scope.valid = ->
    if not $scope.tag_name.match(/^[a-z\d\s\u00E0-\u00FC-]+$/i)
      $scope.errors['tag_name'] = 'Ingrese letras con espacio o números'
      $('#tag-name-input').notify($scope.errors['tag_name'], {position: 'top left', className: 'error'})

    not _.any($scope.errors)

  # notify
  $scope.showSaveErrors = (data, status) ->
    if status < 500
      if data.errors.name
        $scope.errors['tag_name'] = data.errors.name.join(', ')
        $scope.editor.find('#tag-name-input')
        .notify($scope.errors['tag_name'], {className: 'error', positon: 'top center'})
    else
      $scope.editor.parents('div:first')
      .notify('Existió un error al crear', {className: 'error', positon: 'top center'})


  $scope.getFormData = ->
    {tag: {name: $scope.tag_name, bgcolor: $scope.tag_bgcolor}}

# End of function
TagsController.$inject = ['$scope', '$element', '$http', '$timeout', '$window', '$rootScope']
myApp.controller('TagsController', TagsController)
