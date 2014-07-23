# Add remove tags in ta TagGroup
myApp.controller('TagGroupsController', ['$scope', '$window', '$http', '$rootScope', ($scope, $window, $http, $rootScope) ->
  $scope.tags = $window.bonsai.tags
  $scope.selected_tags = []
  $scope.edit = false

  $scope.win = $window

  #
  setEdit = ->
    $scope.title = 'Editar grupo de etiquetas'
    $scope.edit = true
    $scope.id = $window.tag_group.id
    $scope.name = $window.tag_group.name

    $scope.selected_tags = _.where($scope.tags, (tag) ->
      _.include($window.tag_group.tag_ids, tag.id)
    )

    _.each($scope.tags, (tag) ->
      if _.include($window.tag_group.tag_ids, tag.id)
        tag.hide = true
    )

  # Start set for edit
  if $window.tag_group and $window.tag_group.id
    setEdit()
  else
    $scope.title = 'Nuevo grupo de etiquetas'

  # End of set for edit

  $scope.color = Plugins.Tag.textColor

  #
  $scope.select = (tg) ->
    $scope.selected_tags.push(tg)
    tg.hide = true

  #
  $scope.remove = (t, index) ->
    $scope.selected_tags.splice(index, 1)
    tag = _.find($scope.tags, (tg) -> t.id is tg.id)

    tag.hide = false

  tagIds = ->
    _.map($scope.selected_tags, (tag) -> tag.id )

  getData = ->
    {
      name: $scope.name,
      tag_ids: tagIds()
    }


  create = ->
    $scope.submit = true
    $http.post("/tag_groups", { tag_group: getData()})
    .success( (resp) ->
      $scope.submit = false
      $window.history.pushState({resp: resp}, "Grupos de etiquetas", "/tag_groups/#{ resp.id }/edit")
      $scope.title = 'Editar grupo de etiquetas'

      $('#tag-group-button').notify('Se creo correctamente.',
        {className: 'success', position: 'right', autoHideDelay: 3000})
    )
    .error( (resp) ->
      $scope.submit = false
      $('#tag-group-button').notify('Existió un error, por favor intente de nuevo.',
        {className: 'error', position: 'right', autoHideDelay: 3000})
    )

  #
  update = ->
    $scope.submit = true
    $http.put("/tag_groups/#{$scope.id}", { tag_group: getData()})
    .success( (resp) ->
      $scope.submit = false
      $('#tag-group-button').notify('Se actualizo correctamente.',
        {className: 'success', position: 'right', autoHideDelay: 3000})
    )
    .error( (resp) ->
      $scope.submit = false
      $('#tag-group-button').notify('Existió un error, por favor intente de nuevo.',
        {className: 'error', position: 'right', autoHideDelay: 3000})
    )

  #
  $scope.save = ->
    if $scope.edit
      update()
    else
      create()


  $rootScope.$on('newTag', (event, tag) ->
    $scope.tags.push tag
  )

  $rootScope.$on('updatedTag', (event, tag) ->
    ind = _.findIndex($scope.tags, (tg) -> tg.id is tag.id)
    $scope.tags[ind].name = tag.name
    $scope.tags[ind].label = tag.label
    $scope.tags[ind].bgcolor = tag.bgcolor
  )
])
