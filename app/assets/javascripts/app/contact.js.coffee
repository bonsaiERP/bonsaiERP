# Creates a contact
# To use: $('#elem').contactAutocomplete(["Client", "Supplier"], {'model': 'Contact'})
class ContactAutocomplete
  constructor: (@elem, @models, @options)->
    @models  ||= ["Client", "Supplier", "Staff"]
    @options ||= {}

    @model = "Contact"
    @cont  = $(@elem).parents('.input:first')
    @cont.removeClass 'numeric'

    @.setInitial()
    @.setRoutes()
    @.labels()
    @.addAutocompleteField()

  # set Initial values
  setInitial: ->
    @val  = $(@elem).data('val')  || ''
    @type = $(@elem).data('type') || @models[0]
  # Adds the autocomplete field
  addAutocompleteField: ->
    self = @

    @auto_id = @options.id || (new Date).getTime()

    input = $('<input/>').attr(
      'id'      : @auto_id
      'type'    : 'text'
      'size'    : 35
      'name'    : @options.name || @auto_id
      'required': @elem.attr("required")
    ).val(@val)
    .addClass('autocomplete-input')
    .after(self.createAddLink())
    .autocomplete(
      'source': self["route#{self.type}"]
      'select': (e, ui)->
        $(self.elem).val(ui.item.id)
        $(this).data('val', ui.item.label).val(ui.item.label)
        false
      'focus': (e, ui)->
        $(self.elem).val(ui.item.id)
        $(this).data('val', ui.item.label).val(ui.item.label)
        false
    ).focusout ->
      if $(this).val() == ""
        $(self.elem).val('')
      else
        $(this).val( $(this).data('val') )

    $(@elem).hide().before input

  # creates the new link
  createAddLink: ->
    title = "Nuevo #{@.getLocalizedLabel(@type).toLowerCase()}"
    $('<a/>').attr
      'href'   : "/#{@type.toLowerCase()}s/new"
    .addClass('add ajax link')
    .data(
      'title'  : title
      'url'    : @.getAddUrl()
      'trigger': "new_contact_#{@auto_id}"
    )
    .attr({title: title})
    .text(title)
  # Url for adding new contact
  getAddUrl: ->
    "/#{@type.toLowerCase()}s/new"
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
      if k == @type
        css = ""
        sel = "checked='checked'"
      else
        css = "grey"
        sel = ""

      html = "<label class='#{css}'>"
      html += "<input type='radio' class='contact-autocomplete' #{sel} value='#{k}' name='#{name}' />"
      html += "#{@.getLocalizedLabel(k)}</label>"

      arr.push html

    @cont.prepend( $('<div/>').addClass('autocomplete-labels boolean').html arr.join('') )

    # setEvents
    setTimeout ->
      self.setEvents()
    , 500

  # returns a localized label
  getLocalizedLabel: (label) ->
    switch label
      when "Client"   then "Cliente"
      when "Supplier" then "Proveedor"
      when "Staff"    then "Personal"
  # Callback
  getContactCallback: ->
    self = @
    (resp)->
      if self.model == "Contact"
        id   = resp.id
        name = resp.matchcode
      else
        id   = resp.account_id || resp.account.id
        name = resp.account_name || resp.account.name

      $(self.elem).val(id)

      $("#" + self.auto_id).val(name)
      false
  # sets the events for the laels
  setEvents: ->
    self = @

    @cont.find('input:radio').click ->
      self.setSelectedLabel() unless self.type == this.value
    # Add new contact
    callback = @options['callback'] || @.getContactCallback()
    $('body').live "new_contact_#{self.auto_id}", (e, resp)->
      callback(resp)
  # changes the clases for the selected
  setSelectedLabel: ->
    self = @

    $(@cont).find('label').each (i, el) ->
      radio = $(el).find('input:radio')

      if radio.attr("checked")
        $(el).removeClass('grey')
        self.type = radio.val()
      else
        $(el).addClass('grey')
    @.updateAutocomplete()
  # Updates the autocomplete based on the selection
  updateAutocomplete: ->
    self = @
    route = self["route" + @type]
    id = "#" + @auto_id

    title = "Nuevo #{@.getLocalizedLabel(@type).toLowerCase()}"
    $(@cont).find('a.add').attr('href', @.getAddUrl()).
    data(
      'title'  : "Nuevo #{@.getLocalizedLabel(@type).toLowerCase()}"
    )
    .text(title)

    $(id).val('').data('val', '')

    $(@elem).val('')
    $("#{id}")
    .autocomplete('destroy')
    .autocomplete(
      'source': route,
      'select': (e, ui)->
        $(self.elem).val(ui.item.id)
        $(this).data('val', ui.item.label).val(ui.item.label)
        false
      'focus': (e, ui)->
        $(self.elem).val(ui.item.id)
        $(this).data('val', ui.item.label)
        false
    )

(($) ->
  $.fn.contactAutocomplete = (models, options) ->
    new ContactAutocomplete(this, models, options)
)(jQuery)
