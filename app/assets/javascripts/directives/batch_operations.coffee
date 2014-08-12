batchOperations = ($http) ->
  restrict: 'E'
  controller: ($scope, $attrs, $element) ->
    if $attrs.modelType is 'Income'
      $scope.paymentText = 'Cobro multiple'
      $scope.inventoryText = 'Entrega inventario multiple'
    else
      $scope.paymentText = 'Pago multiple'
      $scope.inventoryText = 'Recojo inventario multiple'

    $scope.modelName = $attrs.modelName
    accounts = []

    #
    loadAccounts = ->
      $http.get('/banks/money')
      .success( (resp) ->
        accountsLoaded = true
        accounts = resp
      )

    $scope.movements = []

    $scope.multiplePayments = ->
      $scope.modalTitle = $scope.paymentText
      loadAccounts()  unless accounts.lenght is 0

      $element.find('.pay-button').show()
      $element.find('.inv-button').hide()

      $scope.movements = []
      $('input.row-check:checked').each( (i, el) ->
        $el = $(el)
        $scope.movements.push {
          id: el.id, name: $el.attr('code-name')
        }
      )

      true

    $scope.savePayments = ->


  template: """
  <div class="btn-group">
    <a href="javascript:;" class="btn dropdown-toggle" data-toggle="dropdown">
      Operaciones
      <i class="icon-caret-down"></i>
    </a>
    <ul class="dropdown-menu text-left">
      <li>
        <a href="javascript:;"
        data-target="#multiple-operations-modal" data-toggle="modal"
        ng-click="multiplePayments()">
          {{ paymentText }}
        </a>
      </li>
      <li>
        <a href="javascript:;">{{ inventoryText }}</a>
      </li>
    </ul>
  </div>

  <div class="modal fade" id="multiple-operations-modal">
    <div class="modal-dialog">
      <div class="modal-content l">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span></button>
          <h3>{{ modalTitle }}</h3>
        </div>
        <div class="modal-body">
          <div class="modal-payments">
            Seleccionados:
            <strong ng-repeat="mov in movements">
              {{ mov.name }}
            </strong>

            <h4 class="red" ng-show="movements.length <= 0">Debe seleccionar al menos un {{ modelName }}</h4>

            Seleccione una cuenta
          </div>

          <div class="modal-inventories">
          </div>

        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
          <button type="button" class="btn btn-primary pay-button">{{ paymentText }}</button>
          <button type="button" class="btn btn-primary inv-button">{{ inventoryText }}</button>
        </div>
      </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
  </div>
  """

# End of function

batchOperations.$inject = ['$http']

myApp.directive('batchOperations', batchOperations)
