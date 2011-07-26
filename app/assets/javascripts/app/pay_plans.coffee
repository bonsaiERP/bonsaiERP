class PayPlans
  constructor: ->
    @table  = $('#pay_plans_table')
    @inputs = @table.find('input.check')
    @.setEvents()

  # Events
  setEvents: ->
    self = @
    $('#pay_plans_checkbox').die().live 'click', ->
      if $(this).attr("checked")
        self.inputs.attr("checked", true)
      else
        self.inputs.attr("checked", false)

    $('#destroy_pay_plans_link').die().live 'click', (e)->

      ids = []
      self.inputs.each (i, el)->
        ids.push el.value if $(el).attr("checked")

      if ids.length > 0
        self.destroyPayPlans(ids, this)
      else
        alert "Debe seleccionar al menos un plan de crédito"

      false
  # array of ids
  # @param Array
  # @param DOM
  destroyPayPlans: (ids, elem)->
    $.ajax
      url: $(elem).attr("href")
      type: 'delete'
      data:
        ids: ids
      success: (resp)->
        if resp.success == false
          alert "Existio un error al borrar recargue la página e intente de nuevo borrar"

window.PayPlans = PayPlans
