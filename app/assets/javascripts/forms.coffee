$( ->
  # Parses the date with a predefined format
  # @param String date
  # @param String type : Type to return
  parseDate = (date, typo) ->
    date = $.datepicker.parseDate($.datepicker._defaults.dateFormat, date )
    d = [ date.getFullYear(), date.getMonth() + 1, date.getDate() ]
    if 'string' == type
      d.join("-")
    else
      d

  # Must be before any ajax click event to work with HTMLUnit
  # Makes that a dialog opened window makes an AJAX request and returns a JSON response
  # if response is JSON then trigger event stored in dialog else present the HTML
  # There are three types of response JSON, JavaScript and HTML
  # JavaScript response must have "// javascript" at the beginning
  $('body').on('submit', 'div.ajax-modal form', (event) ->
    return true if $(this).attr('enctype') == 'multipart/form-data'
    return true if $(this).hasClass("no-ajax")

    event.preventDefault()
    # Prevent from submiting the form.enter when hiting ENTER
    return false if $(this).hasClass('enter') and window.keyPress == 13

    $el = $(this)
    data = $el.serialize()
    $el.find('input, select, textarea').attr('disabled', true)

    $div = $el.parents('.ajax-modal:first')
    new_record = if $div.data('ajax-type') == 'new' then true else false
    trigger = $div.data('trigger') or "ajax-call"

    $.ajax(
      'url': $el.attr('action')
      'cache': false
      'context': $el
      'data': data
      'type': (data['_method'] or $el.attr('method') )
    )
    .success (resp, status, xhr) ->
      if typeof resp == "object"
        data['new_record'] = new_record
        $div.html('').dialog('destroy')
        $('body').trigger(trigger, [resp])
      else if resp.match(/^\/\/\s?javascript/)
        $div.html('').dialog('destroy')
      else
        $div.html(resp)
        setTimeout(->
          $div.setDatepicker()
        ,200)
    .error (resp) ->
      alert('There were errors please try again.')
  )
  # End submit ajax form

  popoverNotitle = (options) ->
    $(this).popover(_.merge(options, {
      template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div></div></div>'
    })
    )

  $.popoverNotitle = $.fn.popoverNotitle = popoverNotitle


  ##########################################
  # Activates autocomplete for all autocomplete inputs
  createAutocomplete = ->
    $(this).find('.control-group.autocomplete').each( (i, el) ->
      $this = $(el)
      $hidden = $this.find('[type=hidden]')
      $input = $this.find('[type=text]')

      $input.autocomplete({
        source: $input.data('source'),
        select: (e, ui) ->
          $input.data('value', ui.item.value)
          $hidden.val(ui.item.id)
          $input.trigger('autocomplete-done', [ui.item])
        search: (e, ui) ->
          $input.css({
            backgroundImage: 'url("/assets/ajax-loader-small.gif")',
            backgroundRepeat: 'no-repeat',
            backgroundPosition: "#{$input.width() - 20}px 5px"
          })
        response: (e, ui) ->
          $input.css({backgroundImage: 'none'})
          if ui.content.length is 0
            $input.popoverNotitle({content: 'No se encontraron resultados'})
            $input.popover('show')
            $input.on('focusout', -> $input.popover('destroy'))
          else
            $input.popover('destroy')
        close: (e, ui) -> $input.css({backgroundImage: 'none'})
      }).blur( ->
        $this = $(this)
        value = $this.val()
        if value.trim() == ""
          $hidden.val('')
          $(this).data('value', '')

        $this.val($this.data('value'))
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
    if $this.data('value') != ''
      $a = $this.select2('container').find('>a')
      $a.removeClass('select2-default')
      .find('>span').text($this.data('value'))

  $.select2Autocomplete = $.fn.select2Autocomplete = select2Autocomplete

  # For button tabs
  buttonTab = ->
    $cont = $(this)

    $cont.find('>.buttons-list>.btn-group')
    .on 'click', 'button', () ->
      $cont.find('>.panes>.button-pane').hide()
      $($(this).attr('href')).show()
    .find('button:first').trigger('click')

  $.buttonTab = $.fn.buttonTab = buttonTab

  rowCheck = ->
    $(this).on('click', '>li,>tr', (event) ->
      target = event.target
      return true  if $(target).hasClass('row-check') or target.tagName is 'A'
      
      $check = $(this).find('input.row-check')
      
      if $check.prop('checked')
        $check.prop('checked', false)
      else
        $check.prop('checked', true)
    )

  $.rowCheck = $.fn.rowCheck = rowCheck
)
