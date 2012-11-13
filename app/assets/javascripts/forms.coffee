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

  # Ajax preloader content
  AjaxLoadingHTML = ->
    "<div class='c'><img src='/assets/ajax-loader.gif' alt='Cargando' /><br/>Cargando...</div>"

  window.AjaxLoadingHTML = AjaxLoadingHTML


  # Must be before any ajax click event to work with HTMLUnit
  # Makes that a dialog opened window makes an AJAX request and returns a JSON response
  # if response is JSON then trigger event stored in dialog else present the HTML
  # There are three types of response JSON, JavaScript and HTML
  # JavaScript response must have "// javascript" at the beginning
  $('div.ajax-modal').on( 'form', 'submit', ->
    return true if $(this).attr('enctype') == 'multipart/form-data'
    return true if $(this).hasClass("no-ajax")
    # Prevent from submiting the form.enter when hiting ENTER
    return false if $(this).hasClass('enter') and window.keyPress == 13

    el = this
    data = $(el).serialize()
    $(this).find('input, select, textarea').attr('disabled', true)

    $div = $(this).parents('.ajax-modal')
    new_record = if $div.data('ajax-type') == 'new' then true else false
    trigger = $div.data('trigger') || "ajax-call"

    $.ajax
      'url': $(el).attr('action')
      'cache': false
      'context':el
      'data':data
      'type': (data['_method'] || $(this).attr('method') )
    .done (resp) ->
      if typeof resp == "object"
        data['new_record'] = new_record
        p = $(el).parents('div.ajax-modal')
        $(p).html('').dialog('destroy')
        $('body').trigger(trigger, [resp])
      else if resp.match(/^\/\/\s?javascript/)
        p = $(el).parents('div.ajax-modal')
        $(p).html('').dialog('destroy')
      else
        div = $(el).parents('div.ajax-modal:first')
        div.html(resp)
        setTimeout(->
          $(div).setTransformations()
        ,200)
    .failure (resp) ->
        alert('Existe errores, por favor intente de nuevo.')

    false

  )
  
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
  ##########################################

  $.fn.createAutocomplete = $.createAutocomplete = createAutocomplete


  createSelectOption = (value, label) ->
    opt = "<option selected='selected' value='#{value}'>#{label}</option>"
    $(this).append(opt).val(value).mark()

  $.fn.createSelectOption = $.createSelectOption = createSelectOption

)(jQuery)
