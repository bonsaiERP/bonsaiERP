myApp.controller 'InventoryTransferenceController', ['$scope',  ($scope) ->
  $scope.details = $('#details').data('details')

  # Remove detail item
  $scope.destroy = (index) ->
    if $scope.details.length is 1
      # Alert message
      return

    if $scope.details[index].id?
      $scope.details[index]._destroy = 1
      $scope.details[index].quantity = 0
    else
      $scope.details.splice index, 1
]
