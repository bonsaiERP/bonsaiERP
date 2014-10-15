myApp.factory 'MovementDetail', [ ($resource) ->
  class MovementDetail
    default:
      id: null
      item_id: null
      item: null
      item_old: null
      unit_name: null
      unit_symbol: null
      itemAttributes: {}
      quantity: 1
      price: 0
      original_price: 0
      exchange_rate: 1
      _destroy: 0
      errors: {}
    # const
    constructor: (@attributes) ->
      @[key] = @attributes[key] || val  for key, val of @default
    subtotal: ->
      @price * @quantity
    hasError: (key) ->
      _.any(@errors[key])
    errorsFor: (key) ->
      if @errors[key]? then @errors[key][0] else ''
    valid: ->
      @item_id? and quantity > 0
]
