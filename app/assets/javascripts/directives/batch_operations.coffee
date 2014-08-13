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


    setAccountSelect2 = (accounts) ->
      accounts.forEach (account) -> account.to_s = account.name
      console.log accounts
      # Set select2
      $element.find('#account_to_id').select2(
        data: accounts
        minimumResultsForSearch: if accounts.length > 8 then 1 else -1
        formatResult: Plugin.paymentOptions
        formatSelection: Plugin.paymentOptions
        escapeMarkup: (m) -> m
        dropdownCssClass: 'hide-select2-search'
        placeholder: 'Seleccione la cuenta'
        formatNoMatches: (term) -> 'No se encotro cuentas'
      )
      .on('change', (event) ->
        data = $(this).select2('data')
      )

    #
    loadAccounts = ->
      $http.get('/banks/money')
      .success( (resp) ->
        accountsLoaded = true
        setAccountSelect2(resp)
      )

    $scope.movements = []

    #
    $scope.makePayments = ->
      $scope.paying = true
      ids = $scope.movements.map (mov) -> mov.id

      $http.post($attrs.url, { ids: ids, account_to_id: $scope.account_to_id})
      .success( (resp, status) ->
        $scope.paying = false
        if resp.success
          console.log resp.success
        else
          alert 'Usted no tiene privilegios para realizar esta operación'
      )
      .error(->
        $scope.paying = false
      )

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

            <label>Seleccione una cuenta</label>
            <input type="text" id="account_to_id" ng-model="account_to_id" class="span11" />
          </div>

          <div class="modal-inventories">
          </div>

        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">Cerrar</button>
          <button type="button" class="btn btn-primary pay-button" ng-click="makePayments()" ng-disabled="paying">{{ paymentText }}</button>
          <button type="button" class="btn btn-primary inv-button">{{ inventoryText }}</button>
        </div>
      </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
  </div>
  """

# End of function

batchOperations.$inject = ['$http']

myApp.directive('batchOperations', batchOperations)
