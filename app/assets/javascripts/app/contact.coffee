# Creates a contact
# To use: $('#elem').contactAutocomplete(["Client", "Supplier"], {'model': 'Contact'})
class ContactAutocomplete
  constructor: (@elem, @models, @options)->
    @models ||= ["Client", "Supplier", "Staff"]
    @options ||= {}

    @model = @options.model || "Account"
    @cont = $(@elem).parents('.input:first')
    @cont.removeClass 'numeric'

    @.setRoutes()
    @.labels()
    @.addAutocompleteField()
  # Adds the autocomplete field
  addAutocompleteField: ->
    self = @

    @auto_id = (new Date).getTime()
    $(@elem).hide()
    .after $('<input/>').attr({ 'id': @auto_id, 'type': 'text', 'size': 35 })
      .addClass('autocomplete-input')
      .autocomplete(
        'source': self["route#{self.models[0]}"]
        'select': (e, ui)->
          $(self.elem).val(ui.item.id)
          $(this).data('val', ui.item.label)
      ).focusout ->
        if $(this).val() == ""
          $(self.elem).val('')
        else
          $(this).val( $(this).data('val') )
  # cretes routes based on the model
  setRoutes: ->
    self = @

    for k in @models
      mod = k.toLowerCase()

      switch(self.model)
        when "Contact"
          self["route#{k}"] = "/#{mod}_autocomplete"
        when "Account"
          self["route#{k}"] = "/#{mod}_account_autocomplete"
   # Appends the labels
  labels: ->
    arr = []
    name = (new Date()).getTime()
    self = @
    sel = "checked='checked'"

    for k in @models
      unless k == @models[0]
        css = "grey"
        sel = ""

      html = "<label class='#{css}'>"
      html += "<input type='radio' class='contact-autocomplete' #{sel} value='#{k}' name='#{name}' />"
      html += "#{@.getLocalizedLabel(k)}</label>"

      arr.push html

    @cont.prepend( $('<div/>').addClass('autocomplete-labels boolean').html arr.join('') )

    setTimeout ->
      self.setEvents()
    , 500

  # returns a localized label
  getLocalizedLabel: (label) ->
    switch label
      when "Client"   then "Cliente"
      when "Supplier" then "Proveedor"
      when "Staff"    then "Personal"
  # sets the events for the laels
  setEvents: ->
    self = @

    @cont.find('input:radio').click ->
      self.setSelectedLabel()
  # changes the clases for the selected
  setSelectedLabel: ->
    $(@cont).find('label').each (i, el) ->
      if $(el).find('input').attr("checked")
        $(el).removeClass('grey')
      else
        $(el).addClass('grey')
    @.updateAutocomplete()
  # Updates the autocomplete based on the selection
  updateAutocomplete: ->
    self = @
    route = self["route" + $(@cont).find('input:radio:checked').val()]
    id = "#" + @auto_id

    $(id).val('').data('val', '')
    .autocomplete('destroy')
    .autocomplete(
      'source': route,
      'select': (e, ui)->
        $(self.elem).val(ui.item.id)
        $(this).data('val', ui.item.label)
    )

(($) ->
  $.fn.contactAutocomplete = (models, options) ->
    new ContactAutocomplete(this, models, options)
)(jQuery)
