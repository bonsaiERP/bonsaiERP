$(document).ready(->
  # Velocidad en milisegundos
  speed = 300
  # csfr
  csfr_token = $('meta[name=csfr-token]').attr('content')
  # Date format
  $.dateInputFormat = $.fn.dateInputFormat = 'dd mmm yyyy'

  # Parsea la fecha con formato seleciando a un objeto Date
  # @param String fecha
  # @param String tipo : Tipo de dato a devolver
  parsearFecha = (fecha, tipo)->
    fecha = $.datepicker.parseDate($.datepicker._defaults.dateFormat, fecha )
    d = [ fecha.getFullYear(), fecha.getMonth() + 1, fecha.getDate() ]
    if 'string' == tipo
      d.join("-")
    else
      d

  # Returns the date

  # Transforms the hour to just select 00, 15, 30, 
  transformMinuteSelect = (el, step = 5)->
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
  transformDateSelect = (elem)->
    $(elem).find('.date, .datetime').each((i, el)->
      # hide fields
      input = $('<input/>').attr({ 'class': 'date-transform', 'type': 'text', 'size': 12})
      year = $(el).find('select[name*=1i]').hide().val()
      month = (1 * $(el).find('select[name*=2i]').hide().val()) - 1
      # append input
      day = $(el).find('select[name*=3i]').hide().after( input ).val()
      minute = $(el).find('select[name*=5i]')

      if minute.length > 0 then transformMinuteSelect(minute)

      $(input).dateinput(
        'format': $.dateInputFormat
        'lang': 'es',
        'selectors': true,
        'firstDay': 1,
        'change': ->
          val = this.getValue('yyyy-mm-dd')
          val = val.split('-')
          self = this.getInput()
          $(val).each( (i, el)->
            value = el.replace(/^0([0-9]+$)/, '$1')
            $(self).siblings('select[name*=' + (i + 1) + 'i]').val(value)
          )
      )
    )

  $.transformDateSelect = $.fn.transformDateSelect = transformDateSelect


  ##################################################

  # Asignar la fecha a los elementos siblings del campo con datepicker
  # cuando los campos son select
  setFechaDateSelect = (el)->
    fecha = parsearFecha( $(el).val() )
    $(el).siblings('select[name*=1i]').val(fecha[0])
    $(el).siblings('select[name*=2i]').val(fecha[1])
    $(el).siblings('select[name*=3i]').val(fecha[2])

  # Presenta un tooltip
  $('[tooltip]').live('mouseover mouseout', (e)->
    div = '#tooltip'
    if($(this).hasClass('error') )
      div = '#tooltip-error'

    if(e.type == 'mouseover')
      pos = $(this).position()

      $(div).css(
        'top': pos.top + 'px'
        'left': (e.clientX + 20) + 'px'
      ).html( $(this).attr('tooltip') )
      $(div).show()
    else
      $(div).hide()

  )

  # Para poder presentar mas o menos
  $('a.more').live("click", ->
    $(this).html('Ver menos').removeClass('more').addClass('less').next('.hidden').show(speed)
  )
  $('a.less').live('click', ->
    $(this).html('Ver más').removeClass('less').addClass('more').next('.hidden').hide(speed)
  )


  # Creates the dialog container
  createDialog = (params)->
    params = $.extend({
      'id': new Date().getTime(), 'title': '', 'width': 800, 'height' : 400, 'modal': true, 'resizable' : false
    }, params)
    div = document.createElement('div')
    $(div).attr( { 'id': params['id'], 'title': params['title'], 'data-ajax_id': params['id'] } )
    .addClass('ajax-modal').css( { 'z-index': 1000 } )
    delete(params['id'])
    delete(params['title'])
    $(div).dialog( params )
    div

  #$.fn.createDialog = createDialog

  # Presents an AJAX form
  $('a.ajax').live("click", (e)->
    id = new Date().getTime().toString()
    $(this).attr('data-ajax_id', id)

    div = createDialog( { 'title': $(this).attr('data-title') } )
    $(div).load( $(this).attr("href"), (e)->
      $(div).find('a.new[href*=/], a.edit[href*=/], a.list[href*=/]').hide()
    )
    e.stopPropagation()
    false
  )

  # Para redondear decimales
  roundVal = (val, dec)->
  	dec = dec or 2
	  Math.round(val*Math.pow(10,dec))/Math.pow(10,dec)

  $.roundVal = $.fn.roundVal = roundVal

  # presents the dimesion in bytes
  toByteSize = (bytes)->
    switch true
      when bytes < 1024 then bytes + " bytes"
      when bytes < Math.pow(1024, 2) then roundVal( bytes/Math.pow(1024, 1) ) + " Kb"
      when bytes < Math.pow(1024, 3) then roundVal( bytes/Math.pow(1024, 2) ) + " MB"
      when bytes < Math.pow(1024, 4) then roundVal( bytes/Math.pow(1024, 3) ) + " GB"
      when bytes < Math.pow(1024, 5) then roundVal( bytes/Math.pow(1024, 4) ) + " TB"
      when bytes < Math.pow(1024, 6) then roundVal( bytes/Math.pow(1024, 5) ) + " PB"
      else
        roundVal( bytes/ Math.pow(1024, 6)) + " EB"

  window.tobyteSize = $.toByteSize = $.fn.toByteSize = toByteSize

  # Creation of Iframe to make submits like AJAX requests with files
  setIframePostEvents = (iframe, created)->
    iframe.onload = ->
      html = $(iframe).contents().find('body').html()
      if $(html).find('form').length <= 0 and created
        $('#posts ul:first').prepend(html)
        mark('#posts ul li:first')
        posts = parseInt($('#posts ul:first>li').length)
        postsSize = parseInt($('#posts').attr("data-posts_size") )
        if(posts > postsSize)
          $('#posts ul:first>li:last').remove()
        $('#create_post_dialog').dialog('close')
      else
        created = true
        $('#create_post_dialog').html(html)
  # End setIframeForPost

  # Creates an Iframe to submit
  $('a.post').live('click', ->
    if $('iframe#post_iframe').length <= 0
      iframe = $('<iframe />').attr({ 'id': 'post_iframe', 'name': 'post_iframe', 'style': 'display:none;' })[0]
      $('body').append(iframe)
      setIframePostEvents(iframe, false)
      div = createDialog({'id':'create_post_dialog', 'title': 'Crear comentario'})
    else
      div = $('#create_post_dialog').dialog("open").html("")

    $(div).load( $(this).attr("href") )

    false
  )


  # Hacer submit de un formulario AJAX que permite crear nuevos datos
  # Si al retornar no hay formulario significa que reenvia a una vista
  # y que la transaccion a sido completada
  $('div.ajax-modal form[enctype!=multipart/form-data]').live('submit', ->

    data = serializeFormElements(this)
    el = this

    $.ajax(
      'url': $(el).attr('action')
      'cache': false
      'context':el
      'data':data
      'type': (data['_method'] || $(this).attr('method') )
      'success': (resp, status, xhr)->
        if $(resp).find('input:submit').length <= 0
          p = $(el).parents('div.ajax-modal')
          id = $(p).attr('data-ajax_id')
          $(p).dialog('destroy')
          #$(p).remove()
          $('body').trigger('ajax:complete', [resp])
        else
          $(el).parents('div.ajax-modal:first').html(resp)
      'error': (resp)->
        alert('Existen errores en su formulario por favor corrija los errores')
    )

    false
  )
  # End submit ajax form


  # Cambiar icono para more y less
  #$('ul.menu>li').live('mouseover mouseout', (e)->
  #  $span = $(this).find('.more, .less')
  #  if(e.type == 'mouseover')
  #    $span.removeClass('more').addClass('less')
  #  else
  #    $span.removeClass('less').addClass('more')
  #)

  # Delete an Item
  $('a.delete').live("click", (e)->
    $(this).parents("tr:first, li:first").addClass('marked')
    if(confirm('Esta seguro de borrar el item seleccionado')) 
      url = $(this).attr('href')
      el = this

      $.ajax(
        'url': url
        'type': 'delete'
        'context': el
        'success': ->
          $(el).parents("tr:first, li:first").remove()
          $('body').trigger('ajax:delete', url)
        'error': ->
          alert('Existio un error al borrar')
      )

    else
      $(this).parents("tr:first, li:first").removeClass('marked')
      e.stopPropagation()

    return false
  )

  # Serializes values from a form to be send via AJAX
  serializeFormElements = (elem)->
    params = {}

    $(elem).find('input, select, textarea').each((i, el)->
      params[ $(el).attr('name') ] = $(el).val()
    )

    return params

  $.serializeFormElements = $.fn.serializeFormElements = serializeFormElements

  # Mark
  # @param String // jQuery selector
  # @param Integer velocity
  mark = (selector, velocity, val)->
    val = val or 0
    velocity = velocity or 7
    $(selector).css({'background': 'rgb(255,255,'+val+')'})
    if(val >= 255)
      $(selector).attr("style", "")
      return false
    setTimeout(->
      val += 5
      mark(selector, velocity, val)
    , velocity)

  $.mark = $.fn.mark = mark

  start = ->
    transformDateSelect('body')

  start()
)
