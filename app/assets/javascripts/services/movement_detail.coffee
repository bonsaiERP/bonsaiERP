myApp.factory 'MovementDetail', [ ($resource) ->
  class MovementDetail
    default:
      id: null
      item_id: null
      item: null
      itemAttributes: {}
      quantity: 1
      price: 0
      original_price: 0
    # const
    constructor: (@attributes) ->
      @[key] = @attributes[key] || val  for key, val of @default
    subtotal: ->
      @price * @quantity
]
