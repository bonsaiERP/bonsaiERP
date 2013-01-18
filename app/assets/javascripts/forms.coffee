(($) ->
  # Parses the date with a predefined format
  # @param String date
  # @param String type : Type to return
  parseDate = (date, tipo) ->
    date = $.datepicker.parseDate($.datepicker._defaults.dateFormat, date )
    d = [ date.getFullYear(), date.getMonth() + 1, date.getDate() ]
    if 'string' == tipo
      d.join("-")
    else
      d

  # Sets rails select fields with the correct datthe correct date
  setDateSelect = (el)->
    el = el || this
    date = parseDate( $(el).val() )
    $(el).siblings('select[name*=1i]').val(date[0]).trigger("change")
    $(el).siblings('select[name*=2i]').val(date[1]).trigger("change")
    $(el).siblings('select[name*=3i]').val(date[2]).trigger("change")

  $.setDateSelect = $.fn.setDateSelect = setDateSelect

  # Transforms the hour to just select 00, 15, 30, 
  transformMinuteSelect = (el, step = 5) ->
    $el = $(el)
    val = $el.val()
    steps = parseInt(60/5) - 1
    options = []
    for k in [0..steps]
      if el == val then sel = 'selected="selected"' else sel =""
      options.push('<option value="' + (5 * k) + '" ' + sel + '>' + (5 * k) + '</option>')
    options = options.join("")

    $(el).html(options)

  # Transforms a dateselect field in rails to jQueryUI
  transformDateSelect = ->
    $(this).find('.date, .datetime').each((i, el)->
      # hide fields
      input = document.createElement('input')
      $(input).attr(
        class: 'date-transform'
        type: 'text'
        size: 10
      )

      year = $(el).find('select[name*=1i]').hide().val()
      month = (1 * $(el).find('select[name*=2i]').hide().val()) - 1
      day = $(el).find('select[name*=3i]').hide().after( input ).val()
      minute = $(el).find('select[name*=5i]')

      if minute.length > 0 then transformMinuteSelect(minute)

      # Only after added to DOM one must set button
      $(input).datepicker(
        yearRange: '1900:',
        showOn: 'both',
        buttonImageOnly: true,
        buttonImage: '/assets/calendar-black.png'
      )
      $(input).change( (e) ->
        $.setDateSelect(this)
        $(this).trigger("change:datetime", this)
      )

      if year != '' and month != '' and day != ''
        $(input).datepicker("setDate", new Date(year, month, day))
      $('.ui-datepicker').not('.ui-datepicker-inline').hide()
    )

  $.transformDateSelect = $.fn.transformDateSelect = transformDateSelect

  $(document).on('ajax:success', 'div.ajax-modal form', (event, resp) ->
    switch true
      when _.isString(resp)
        $parent = $(this).parents('div.ajax-modal')
        $parent.html(resp)
        $parent.find('form').attr('data-remote', true)
      when _.isObject(resp)
        $parent = $(this).parents('div.ajax-modal')
        if trigger = $parent.data('trigger')
          $(this).trigger trigger, [resp]

        $parent.dialog('destroy')
      else
        console.log resp

  )

  ##########################################
  # Activates autocomplete for all autocomplete inputs
  createAutocomplete = ->
    $(this).find('.control-group.autocomplete').each( (i, el) ->
      $this = $(el)
      $hidden = $this.find('[type=hidden]')
      $input = $this.find('[type=text]')
      $input.data('value', $hidden.val())

      $input.autocomplete({
        'source': $input.data('source'),
        'select': (e, ui) ->
          $input.data('value', ui.item.value)
          $hidden.val(ui.item.id)
          $input.trigger('autocomplete-done', [ui.item])

      }).blur(->
        value = $(this).val()
        if value.trim() == ""
          $hidden.val('')
          $(this).data('value', '')
        else
          $(this).val($(this).data('value'))
      )
    )

  $.fn.createAutocomplete = $.createAutocomplete = createAutocomplete

  ##########################################
  # Datepicker for simple_form
  setDatepicker = ->
    $(this).find('.control-group.datepicker:not(.hasDatepicker)').each (i, el) ->
      $this = $(el)
      $this.addClass 'hasDatepicker'
      $hidden = $this.find '[type=hidden]'
      $picker = $this.find '[type=text]'

      if $hidden.val()
        date = $.datepicker.parseDate('yy-mm-dd', $hidden.val())
        date = $.datepicker.formatDate($.datepicker._defaults.dateFormat, date)
        $picker.val(date)
      else
        value = ''

      $picker.datepicker
        yearRange: '1900:'
        showOn: 'both'
        buttonImageOnly: true
        buttonImage: '/assets/bicon/date.png'
        altFormat: 'yy-mm-dd'
        altField: $hidden.get(0)

  $.setDatepicker = $.fn.setDatepicker = setDatepicker
  ########################################

  createSelectOption = (value, label) ->
    opt = "<option selected='selected' value='#{value}'>#{label}</option>"
    $(this).append(opt).val(value).mark()

  $.fn.createSelectOption = $.createSelectOption = createSelectOption

  ########################################
  # Select2
  $.fn.select2.defaults = _.merge($.fn.select2.defaults, {
    numCars: (n) -> if n == 1 then "" else "es"
    formatResultCssClass: -> undefined
    formatNoMatches: -> "No se encontro"
    formatInputTooShort: (input, min) -> 
      n = min - input.length
      "Ingrese #{n} caracter#{@numCars(n)} mas"
    formatInputTooLong: (input, max) -> 
      n = input.length - max
      "Ingrese #{n} caracter#{@numCars(n)} menos"
    ###
    formatSelectionTooBig: ->
      #function (limit) { return "You can only select " + limit + " item" + (limit == 1 ? "" : "s"); },
    ###
    formatLoadMore: -> "Cargando resultados..."
      #function (pageNumber) { return "Loading more results..."; },
    formatSearching: -> "Buscando..."
  })

  select2Autocomplete = (el) ->
    $this = $(this)

    $this.select2(
      minimumInputLength: 2
      ajax: {
        url: $this.data('source')
        dataType: 'json'
        data: (term) ->
          { q: term }
        results: (data, page) ->
          {results: data}
      }
      formatResult: (res) ->
        "#{res.to_s}"
      formatSelection: (res) ->
        "#{res.to_s}"
    )

  $.fn.select2Autocomplete = select2Autocomplete
)(jQuery)

