# Creates a contact
class ContactAutocomplete
  constructor: (@elem, @models, @options)->
    @models ||= ["Client", "Supplier", "Staff"]
    @options ||= {}

    @model = @options.model || "Account"
    @cont = $(@elem).parents('.input:first')
    @cont.removeClass 'numeric'

    @.routes()
    @.labels()
  # cretes routes based on the model
  routes: ->
    self = @

    for k in @models
      mod = k.toLowerCase()

      switch(self.model)
        when "Contact"
          self["route_#{mod}"] = "/#{mod}_autocomplete"
        when "Account"
          self["route_#{mod}"] = "/#{mod}_account_autocomplete"
   # Appends the labels
  labels: ->
    arr = []
    name = (new Date()).getTime()
    self = @

    for k in @models
      html = "<label>"
      html += "<input type='radio' class='contact-autocomplete' value='#{k}' name='#{name}' />"
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
    @cont.find('input:radio').click ->
      console.log $(this).val()


(($) ->
  $.fn.contactAutocomplete = (models, options) ->
    new ContactAutocomplete(this, models, options)
)(jQuery)
