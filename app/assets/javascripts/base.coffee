######################################
# All events related to jQuery
( ($) ->
  # Regional settings for jquery-ui datepicker
  $.datepicker.regional['es'] = {
    closeText: 'Cerrar',
    prevText: '&#x3c;Ant',
    nextText: 'Sig&#x3e;',
    currentText: 'Hoy',
    monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio',
    'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
    monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun',
    'Jul','Ago','Sep','Oct','Nov','Dic'],
    dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
    dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
    dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
    weekHeader: 'Sm',
    dateFormat: 'dd/mm/yy',
    firstDay: 1,
    isRTL: false,
    showMonthAfterYear: false,
    yearSuffix: ''
  }
  $.datepicker.setDefaults($.datepicker.regional['es'])

  # Effect fro dropdown
  initjDropDown = ->
    $(this).find('li').bind 'mouseover mouseout', (event)->
      if event.type == 'mouseover'
        $(this).addClass('marked')
      else
        $(this).removeClass('marked')
  $.initjDropDown = $.fn.initjDropDown = initjDropDown

  # Speed in milliseconds
  speed = 300
  # csfr
  csrf_token = $('meta[name=csrf-token]').attr('content')
  window.csrf_token = csrf_token
  # Date format
  $.datepicker._defaults.dateFormat = 'dd M yy'


  ##################################################

  # Creates the dialog container
  createDialog = (params)->
    data = params
    params = $.extend({
      'id': new Date().getTime(), 'title': '', 'width': 800, 'modal': true, 'resizable' : false, 'position': 'top',
      'close': (e, ui)->
        $('#' + div_id ).parents("[role=dialog]").detach()
    }, params)
    html = params['html'] || AjaxLoadingHTML()
    div_id = params.id
    div = document.createElement('div')
    css = "ajax-modal " + params['class'] || ""
    $(div).attr( { 'id': params['id'], 'title': params['title'] } ).data(data)
    .addClass(css).css( { 'z-index': 10000 } ).html(html)
    delete(params['id'])
    delete(params['title'])

    $(div).dialog( params )

    div

  window.createDialog = createDialog

  # Opens a video dialog
  createVideoDialog = (url, title = "")->
    #html = "<iframe width=\"640\" height=\"360\" src=\"#{url}\" frameborder=\"0\" allowfullscreen></iframe>"
    html = "<iframe width=\"853\" height=\"480\" src=\"#{url}\" frameborder=\"0\" allowfullscreen></iframe>"
    #createDialog({html: html, width: 680, height: 410, title: title})
    createDialog({html: html, width: 880, height: 530, title: title})

  window.createVideoDialog = createVideoDialog
  $('a.video').live 'click', (event)->
    createVideoDialog($(this).attr("href"), $(this).data("title"))
    false

  # Gets if the request is new, edit, show
  getAjaxType = (el)->
    if $(el).hasClass("new")
      'new'
    else if $(el).hasClass("edit")
      'edit'
    else
      'show'

  window.getAjaxType = getAjaxType


  # Presents an AJAX form
  $('a.ajax').live("click", (event)->
    title = $(this).attr("title") || $(this).data("original-title")
    data = $.extend({'title': title, 'ajax-type': getAjaxType(this) }, $(this).data() )
    div = createDialog( data )
    $( div ).load( $(this).attr("href"), (resp)->
      $(div).setTransformations()
      $(div).find('form').attr('data-remote', true)
    )

    event.stopPropagation()
    false
  )

  # To present the search
  $('a.search').live("click", ->
    search = $(this).attr("href")
    $(search).show(speed)
  )


  # Delete an Item from a list, deletes a tr or li
  # Very important with default fallback for trigger
  $('a.delete[data-remote=true]').live("click", (e)->
    self = this
    $(self).parents("tr:first, li:first").addClass('marked')
    trigger = $(self).data('trigger') || 'ajax:delete'

    conf = $(self).data('confirm') || 'Esta seguro de borrar el item seleccionado'

    if(confirm(conf))
      url = $(this).attr('href')
      el = this
      $.ajax(
        'url': url
        'type': 'delete'
        'context': el
        'data': {'authenticity_token': csrf_token }
        'success': (resp, status, xhr)->
          if typeof resp == "object"
            if resp['destroyed?'] or resp.success
              $(el).parents("tr:first, li:first").remove()
              $('body').trigger(trigger, [resp, url])
            else
              $(self).parents("tr:first, li:first").removeClass('marked')
              error = resp.errors || ""
              alert("Error no se pudo borrar: #{error}")
          else if resp.match(/^\/\/\s?javascript/)
            $(self).parents("tr:first, li:first").removeClass('marked')
          else
            alert('Existio un error al borrar')
        'error': ->
          $(self).parents("tr:first, li:first").removeClass('marked')
          alert('Existio un error al borrar')
      )
    else
      $(this).parents("tr:first, li:first").removeClass('marked')
      e.stopPropagation()

    false
  )

  # Method to delete when it's in the .links in the top
  $('a.delete').live 'click', ->
    return false if $(this).attr("data-remote")

    txt = $(this).data("confirm") || "Esta seguro de borrar"
    unless confirm(txt)
      false
    else
      html = "<input type='hidden' name='utf-8' value='&#x2713;' />"
      html += "<input type='hidden' name='authenticity_token' value='#{csrf_token}' />"
      html += "<input type='hidden' name='_method' value='delete' />"

      form = $('<form/>').attr({'method': 'post', 'action': $(this).attr('href') })
      .html(html).appendTo('body').submit()

      false

  # Mark
  # @param String // jQuery selector
  # @param Integer velocity
  mark = (selector, velocity, val) ->
    self = selector or this
    val = val or 0
    velocity = velocity or 50
    $(self).css({'background': 'rgb(255,255,'+val+')'})
    if(val >= 255)
      $(self).attr("style", "")
      return false
    setTimeout(->
      val += 5
      mark(self, velocity, val)
    , velocity)

  $.mark = $.fn.mark = mark

  # Adds a new link to any select with a data-new-url
  dataNewUrl = ->
    $(this).find('[data-new-url]').each((i, el) ->
      data = $.extend({width: 800}, $(el).data() )
      title = data.title || "Nuevo"

      $a = $('<a/>')
      .attr({'href': data.newUrl, 'class': 'bicon-add ajax', 'title': title, rel: 'tooltip' })
      .data({'trigger': data.trigger, 'width': data.width})
      .css("margin-left", "5px")

      $a.insertAfter(el)
    )

  $.fn.dataNewUrl = dataNewUrl

  # Closes the nearest div container
  $('a.close').live 'click', ->
    self = @
    cont = $(@).parents('div:first').hide(speed)
    unless $(@).parents("div:first").hasClass("search")
      setTimeout ->
        cont.remove()
      ,speed

  createErrorLog = (data)->
    unless $('#error-log').length > 0
      $('<div id="error-log" style="background: #FFF"></div>')
      #.html("<iframe id='error-iframe' width='100%' height='100%'><body></body></iframe>")
      .dialog({title: 'Error', width: 900, height: 500})

    #$('#error-iframe').contents().find('body').html(data)
    $('#error-log').html(data).dialog("open")

  # Creates a message window with the text passed
  # @param String: HTML to insert inside the message div
  # @param Object
  createMessageCont = (text, options)->
    "<div class='message'><a class='close' href='javascript:'>Cerrar</a>#{text}</div>"

  window.createMessageCont = createMessageCont

  # Hide message
  $('.message .close').live("click", ->
    $(this).parents(".message:first").hide("slow").delay(500).remove()
  )

  # AJAX setup
  $.ajaxSetup ({
    #dataType : "html",
      beforeSend : (xhr)->
        #$('#cargando').show();
      error : (event) ->
        #$('#cargando').hide(1000)
        #createErrorLog(event.responseText)
      complete : (event)->
        if $.inArray(event.status, [404, 422, 500]) >= 0
          createErrorLog(event.responseText)
        #$('#cargando').hide(1000)
      success : (event)->
        #$('#cargando').hide(1000)
    })

  # Prevent enter submit forms in some forms
  window.keyPress = false
  $('form.enter input').live 'keydown', (event)->
    window.keyPress = event.keyCode || false
    true

  $('form.enter input:submit').live 'mouseover', ->
    window.keyPress = false
    true

  $('form.enter').live 'submit', (event)->
    if window.keyPress == 13
      false
    else
      true

  # Supress from submiting a form from an input:text
  checkCR = (evt)->
    evt  = evt  = (evt) ? evt : ((event) ? event : null)
    node = evt.target || evt.srcElement
    if evt.keyCode == 13 and node.type == "text" then false

  document.onkeypress = checkCR

  # For the modal forms and dialogs
  setTransformations = ->
    $(this).setDatepicker()
    $(this).createAutocomplete()

  $.fn.setTransformations = setTransformations

  # Wrapped inside this working
  $(document).ready ->
    $('body').tooltip( selector: '[rel=tooltip]' )
    $('body').setDatepicker()
    $('body').createAutocomplete()
    $('body').dataNewUrl()
    fx.rates = exchangeRates.rates

  rivets.configure(
    adapter:
      subscribe: (obj, keypath, callback) ->
        obj.on('change:' + keypath, callback)
      unsubscribe: (obj, keypath, callback) ->
        obj.off('change:' + keypath, callback)
      read: (obj, keypath) ->
        obj.get(keypath)
      publish: (obj, keypath, value) ->
        obj.set(keypath, value)
  )

  rivets.formatters.number = (value) ->
    _b.ntc(value)

  true
)(jQuery)
