myApp.factory 'MovementDetail', [ ($resource) ->
  class MovementDetail
    default:
      id: null
      item_id: null
      item: null
      item_old: null
      itemAttributes: {}
      quantity: 1
      price: 0
      original_price: 0
      exchange_rate: 1
    # const
    constructor: (@attributes) ->
      @[key] = @attributes[key] || val  for key, val of @default
    subtotal: ->
      @price * @quantity
]
