$(->
  # Transforms a dateselect field in rails to jQueryUI
  transformDateSelect = ->
    $(this).find('.date, .datetime').each((i, el)->
      # hide fields
      input = document.createElement('input')
      $(input).attr({ 'class': 'date-transform', 'type': 'text', 'size': 10 })
      year = $(el).find('select[name*=1i]').hide().val()
      month = (1 * $(el).find('select[name*=2i]').hide().val()) - 1
      day = $(el).find('select[name*=3i]').hide().after( input ).val()
      minute = $(el).find('select[name*=5i]')

      if minute.length > 0 then transformMinuteSelect(minute)

      # Solo despues de haber adicionado al DOM hay que 
      # usar datepicker si se define el boton
      $(input).datepicker(
        yearRange: '1900:',
        showOn: 'both',
        buttonImageOnly: true,
        buttonImage: '/assets/images/calendar.gif'
        #onSelect: (dateText, inst)->
          #  $.setDateSelect(inst.input)
      )
      $(input).change((e)->
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

)
