# Controller for incomes and expenses
MovementController = ($scope, $window, MovementDetail) ->

  $scope.currency = $('#currency').val()
  $scope.same_currency = true
  $scope.details = []
  $scope.direct_payment = $('#direct_payment').prop('checked')
  $scope.tax_in_out = $('#tax_in_out').prop('checked')
  $scope.tax_label = 'Por fuera'
  $scope.taxes = angular.element('#taxes').data('taxes')
  $scope._destroy = '0'
  #$scope.exchange_rate = $('#exchange_rate').val() * 1
  $scope.calls = 0
  $scope.accounts = angular.element('#accounts').data('accounts')

  $scope.same_currency = $scope.currency is $window.organisation.currency

  # Set tax
  tax_id = $('#tax_id').val() * 1
  $scope.tax = _.find $scope.taxes, (v) -> v.id == tax_id  if tax_id > 0


  # ng-class Does not work fine with bootstrap buttons javascript
  $('#tax-in-out-btn').addClass('active')  if $scope.tax_in_out
  $('#direct-payment-button').addClass('active')  if $scope.direct_payment

  # initialize items
  for det in $('#details').data('details')
    det.item_old = det.item
    det.price = parseFloat(det.price)
    det.quantity = parseFloat(det.quantity)
    $scope.details.push(new MovementDetail(det))

  # Remove an item
  $scope.destroy = (index) ->
    if $scope.details.length is 1
      # Alert message
      return

    if $scope.details[index].id?
      $scope.details[index]._destroy = 1
      $scope.details[index].quantity = 0
    else
      $scope.details.splice index, 1

  # Changes the exchange_rates on the details
  $scope.updateDetailsExchangeRate = (rate) ->

  # Check for the change in currency and activate all methods
  $scope.$watch 'currency', (current, old, scope) ->
    unless current is old
      curr = $window.organisation.currency
      scope.same_currency = current is curr
      scope.exchange_rate = fx.convert(1, { from: current, to: curr }).toFixed(4) * 1
      # Sel all clases to correct currency
      $('.currency').html(_b.currencyLabel scope.currency)

  # Check for cahnges on exchange_rate to update details
  $scope.$watch 'exchange_rate', ->
    $scope.calls += 1
    return  if $scope.calls is 1
    for det in $scope.details
      det.price = _b.roundVal(det.original_price / $scope.exchange_rate, 2)


  # add details
  $scope.addDetail = ->
    $scope.details.push new MovementDetail({quantity: 1})

  # Tax id
  $scope.setTaxId = -> $scope.tax_id = $scope.tax.id

  # Tax label
  $scope.taxLabel = ->
    if $scope.tax_in_out is true then 'Por dentro' else 'Por fuera'


  # Subtotal
  $scope.subtotal = ->
    _.reduce( $scope.details, (s, det) ->
      s += det.subtotal()
    , 0)


  $scope.taxTotal = ->
    sub = $scope.subtotal()
    if $scope.tax and $scope.tax_in_out
      sub - ( sub / (1 + $scope.tax.percentage / 100) )
    else if $scope.tax and $scope.tax_in_out is false
      sub * ( $scope.tax.percentage / 100)
    else
      0

  # total
  $scope.total = ->
    if $scope.tax_in_out
      $scope.subtotal()
    else
      $scope.subtotal() + $scope.taxTotal()

  # Any valid item
  $scope.anyValidItem = ->
    _.any( _.map($scope.details, (det) -> det.valid() ) )

  # Validation using jquery, not really angular way
  $('form.movement-form').on 'submit', (event) ->
    if $scope.anyValidItem()
      true
    else
      event.preventDefault()
      $.notify('Debe seleccionar al menos un ítem', { className: 'error', position: 'top right' })

  # Add new item with add button
  $('body').on 'ajax-call', '.movement-details a.add-new-item', (event, resp) ->
    scope = $(this).parents('li.row-fluid:first').scope()

    scope.$apply (sc) ->
      sc.detail.exchange_rate = $scope.exchange_rate
      sc.detail.item = resp.label
      sc.detail.item_old = resp.label
      sc.detail.item_id = resp.id
      sc.detail.price = _b.roundVal(resp.price / $scope.exchange_rate, 2)
      sc.detail.original_price = resp.price

  $('body').on 'ajax-call', 'a.add-new-tax', (event, resp) ->
    $scope.$apply (scope) ->
      tax = { id: resp.id, name: resp.name, percentage: resp.percentage }
      scope.taxes.push tax
      scope.tax = tax
      scope.tax_id = tax.id
########################################
# End of function

MovementController.$inject = ['$scope', '$window', 'MovementDetail']
myApp.controller('MovementController', MovementController)
