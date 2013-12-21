# Controller for incomes and expenses
myApp.controller 'MovementController', ['$scope', 'MovementDetail', ($scope, MovementDetail) ->

  $scope.currency = $('#currency').val()
  $scope.same_currency = true
  $scope.details = []
  #  new MovementDetail(price: 1, quantity: 1),
  #  new MovementDetail(price: 2, quantity: 10)
  #]

  # initialize items
  _.each $('#details').data('details'), (det) ->
    $scope.details.push(new MovementDetail(det))

  $scope.destroy = (index) ->
    if $scope.details.length is 1
      # Alert message
      return
    $scope.details.splice index, 1

]
