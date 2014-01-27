########################################
# Base class
class InlineEdit
  data: {}
  constructor: (event, @$link) ->
    @$parent = @$link.parents('.inline-cont:first')
    @$parent.hide()
    @notify = @$link.data('notify') || '.top-left'
    @url = @$link.attr('href')
    @name = @$link.data('name')

    @$data = @$parent.find('.inline-data')
    @value = @$data.data('value') || @$data.text()
    @setTemplate()
  #
  setButtons: ->
    self = @
    @$save = @$template.find('.save')
    @$cancel = @$template.find('.cancel').on 'click', ->
      self.$parent.show()
      self.$template.remove()
  #
  disableSave: ->
    @$save.prop('disabled', true)


########################################
# Textarea
class TextareaEdit extends InlineEdit
  template: """
  <div class="inline-form-edit">
    <textarea cols="[:cols:]" rows="[:rows:]">[:value:]</textarea>
    <div>
      <button class="btn btn-primary btn-small save">Salvar</button>
      <button class="btn btn-small cancel">Cancelar</button>
    </div>
  </div>
  """
  setTemplate: ->
    [rows, cols] = [(@$link.data('rows') || 4), (@$link.data('cols') || 40)]
    @$template = $(_.template @template, value: @value, cols: cols, rows: rows)
    .insertAfter(@$parent)
    @$editor = @$template.find('textarea')
    @setButtons()
    @setEvents()
  #
  setEvents: ->
    @$save.click =>
      @data[@name] = @value = @$editor.val()
      @update(@data)
  #
  update: (data) ->
    self = @
    @disableSave()
    $.ajax(
      method: 'patch'
      data: data
      url: @url
    )
    .done (resp) ->
      if resp.success || resp.id
        self.$data.html _b.nl2br(self.value)
        self.$parent.show()
        self.$template.remove()
        self.$data.data 'value', self.value
    .fail (resp) ->
      $(self.notify).notify({
        type:'error',
        message: { text: resp.errors }
      }).show()


########################################
# Textarea
class DateEdit extends InlineEdit
  template: """
  <div class="inline-form-edit">
    <div class="datepicker">
      <input type="hidden"/>
      <input type="text" value="[:value:]" size="10"/>
      <div class="ib nw">
        <button class="btn btn-primary btn-small save">Salvar</button>
        <button class="btn btn-small cancel">Cancelar</button>
      </div>
    </div>
  </div>
  """
  setTemplate: ->
    @due = @$link.data('due') || false
    @$template = $(_.template @template, value: @value)
    .insertAfter(@$parent)
    @$template.setDatepicker()
    @$editor = @$template.find('input:text')
    @$hidden = @$template.find('input:hidden')
    @setButtons()
    @setEvents()
  #
  setEvents: ->
    @$save.click =>
      @data[@name] = @$hidden.val()
      @value = @$editor.val()
      @valueDate = @$editor.datepicker('getDate')
      @update(@data)
  #
  update: (data) ->
    self = @
    @disableSave()
    $.ajax(
      method: 'patch'
      data: data
      url: @url
    )
    .done (resp) ->
      if resp.success || resp.id
        self.setDate()
        self.$data.data 'value', self.value
        self.$parent.show()
        self.$template.remove()
    .fail (resp) ->
      $(self.notify).notify({
        type:'error',
        message: { text: resp.errors }
      }).show()
  #
  setDate: ->
    if @due && @isDue()
      @$data.html "<span class='red'>#{@value}</span>"
    else
      @$data.text @value
  #
  isDue: ->
    today = $.datepicker.parseDate 'yy-mm-dd', @$link.data('today')
    @valueDate < today


########################################
# Number
class NumberEdit extends InlineEdit
  template: """
  <div class="inline-form-edit">
    <input type="text" value="[:value:]" size="10" class="r" />
    <div class="nw ib">
      <button class="btn btn-primary btn-small save">Salvar</button>
      <button class="btn btn-small cancel">Cancelar</button>
    </div>
  </div>
  """
  errors: {}
  #
  setTemplate: ->
    @$template = $(_.template @template, value: @value)
    .insertAfter(@$parent)
    @validate = @$link.data('validate')
    @minimum = @$link.data('minimum')
    @maximum = @$link.data('maximum')
    @$editor = @$template.find('input:text')
    @setButtons()
    @setEvents()
  #
  setEvents: ->
    @$save.click =>
      @data[@name] = @value = @$editor.val()
      if @validateData()
        @update(@data)
  #
  update: (data) ->
    self = @
    @disableSave()
    $.ajax(
      method: 'patch'
      data: data
      url: @url
    )
    .done (resp) ->
      if resp.success || resp.id
        self.$data.html _b.ntc(self.value)
        self.$parent.show()
        self.$template.remove()
        self.$data.data 'value', self.value
    .fail (resp) ->
      $(self.notify).notify({
        type:'error',
        message: { text: resp.errors }
      }).show()
  #
  validateData: ->
    @$template.removeClass 'field_with_errors'
    @errors = {}

    @validNumber()
    @validateMinimum()  if @minimum?
    @validateMaximum()  if @maximum?

    if _.any(@errors)
      @showErrors()
      false
    else
      true
  #
  validNumber: ->
    unless _b.isNumber @value
      @errors['number'] = 'Debe ingresar un número'
  #
  validateMinimum: ->
    if @value < @minimum
      @errors['minimum'] = "El valor es menor que mínimo #{@minimum}"
  #
  validateMaximum: (errors) ->
    if @value > @maximum
      @errors['maximum'] = "El valor es mayor que máximo #{@maximum}"
  #
  showErrors: ->
    @$template.addClass 'field_with_errors'
    text = []
    for k, v of @errors
      text.push v

    $(@notify).notify(
      type: 'error',
      message: { text: text.join(', ') }
    ).show()


$(document).ready ->
  $('body').on 'click', '.inline-edit', (event) ->
    event.preventDefault()
    $this = $(this)
    switch $this.data('type')
      when 'text'
        new TextEdit(event, $this)
      when 'textarea'
        new TextareaEdit(event, $this)
      when 'date'
        new DateEdit(event, $this)
      when 'number'
        new NumberEdit(event, $this)
