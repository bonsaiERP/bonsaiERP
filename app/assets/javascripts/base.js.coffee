######################################
# All events related to jQuery
$(document).ready(->
  # Fix some issues with MSIE 7
  #if $.browser.msie and $.browser.version < 8
  #  $('#main_menu li.more').live("mouseover", ->
  #    $(this).show()
  #  )

  # Speed in milliseconds
  speed = 300
  # csfr
  csrf_token = $('meta[name=csrf-token]').attr('content')
  window.csrf_token = csrf_token
  # Date format
  $.datepicker._defaults.dateFormat = 'dd M yy'

  # Parses the date with a predefined format
  # @param String date
  # @param String type : Type to return
  parseDate = (date, tipo)->
    date = $.datepicker.parseDate($.datepicker._defaults.dateFormat, date )
    d = [ date.getFullYear(), date.getMonth() + 1, date.getDate() ]
    if 'string' == tipo
      d.join("-")
    else
      d

  # Creates an autocomplete field
  # @param Object
  createAutocompleteField = (options)->
    options = $.extend({}, options)
    self = @
    val = $(@).data('value') || ""
    id = new Date().getTime()
    required= $(@).attr('required')

    $input = $('<input/>').attr({'size': $(this).attr('size'), 'type':'text', 'id': id, 'required': required})

    .css({'text-align':'left'}).addClass('autocomplete_view')
    .val(val)
    $(@).hide().before($input)

    $("##{id}").live('focusout', ->
      if $(@).val() == ""
        $(self).val('').data('value', '')
      else
        $(@).val($(self).data('value'))
    ).autocomplete({
      source: options.source || $(@).data('url'),
      select: (e, ui)->
        $(@).siblings('input').data('value', ui.item.label).val(ui.item.id)
    })


  $.createAutocompleteField = $.fn.createAutocompleteField = createAutocompleteField

  # Create autocomplete for items
  #$('input.autocomplete').createAutocompleteField()

  # Sets rails select fields with the correct datthe correct date
  setDateSelect = (el)->
    el = el || this
    date = parseDate( $(el).val() )
    $(el).siblings('select[name*=1i]').val(date[0]).trigger("change")
    $(el).siblings('select[name*=2i]').val(date[1]).trigger("change")
    $(el).siblings('select[name*=3i]').val(date[2]).trigger("change")

  $.setDateSelect = $.fn.setDateSelect = setDateSelect

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


  ##################################################

  # Presents a tooltip
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

  # Ajax preloader content
  AjaxLoadingHTML = ->
    "<div class='c'><img src='/assets/ajax-loader.gif' alt='Cargando' /><br/>Cargando...</div>"

  window.AjaxLoadingHTML = AjaxLoadingHTML

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


  # Must be before any ajax click event to work with HTMLUnit
  # Makes that a dialog opened window makes an AJAX request and returns a JSON response
  # if response is JSON then trigger event stored in dialog else present the HTML
  # There are three types of response JSON, JavaScript and HTML
  # JavaScript response must have "// javascript" at the beginning
  $('div.ajax-modal form').live('submit', ->
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

    $.ajax(
      'url': $(el).attr('action')
      'cache': false
      'context':el
      'data':data
      'type': (data['_method'] || $(this).attr('method') )
      'success': (resp, status, xhr)->

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
            $(div).transformDateSelect()
          ,200)
      'error': (resp)->
        alert('Existe errores, por favor intente de nuevo.')
    )

    false

  )
  # End submit ajax form

  # Presents an AJAX form
  $('a.ajax').live("click", (e)->
    data = $.extend({'title': $(this).attr('title'), 'ajax-type': getAjaxType(this) }, $(this).data() )
    div = createDialog( data )
    $(div).load( $(this).attr("href"), (e)->
      #$(div).find('a.new[href*=/], a.edit[href*=/], a.list[href*=/]').hide()
      $(div).transformDateSelect()
    )
    e.stopPropagation()
    false
  )

  # To present the search
  $('a.search').live("click", ->
    search = $(this).attr("href")
    $(search).show(speed)
  )


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


  # Function that handles the return of an AJAX request and process if add or replace
  # @param String template: HTML template
  # @param Object data: JSON data
  # @param String macro: jQuery function for insert, ["insertBefore", "insertAfter", "appendTo"]
  # @param String node: Indicates the node type ['tr', 'li']
  updateTemplateRow = (template, data, macro)->
    if $.inArray(macro, ["insertBefore", "insertAfter", "appendTo"]) < 0
      macro = "insertAfter"

    if(data['new_record'])
      $node = $.tmpl(template, data)[macro](this)
    else
      $node = $(this).find("##{data.id}")
      tmp = $.tmpl(template, data).insertBefore($node)
      $node.detach()
      $node = tmp
    $node.mark()
    $('body').trigger("update:template", [$node, data])

  $.updateTemplateRow = $.fn.updateTemplateRow = updateTemplateRow


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
  mark = (selector, velocity, val)->
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
  $('[data-new_url]').each((i, el)->
    data = $(el).data()
    title = data.title || "Nuevo"
    $a = $('<a/>')
    .attr({'href': data.new_url, 'class': 'ajax add link', 'data-trigger': data.trigger })
    .text(title)

    $a.insertAfter(el)
    setTimeout(->
      $a.attr('title', title)
    , 100)
  )

  # Closes the nearest div container
  $('a.close').live 'click', ->
    self = @
    cont = $(@).parents('div:first').hide(speed)
    unless $(@).parents("div:first").hasClass("search")
      setTimeout ->
        cont.remove()
      ,speed

  createSelectOption = (value, label)->
    opt = "<option selected='selected' value='#{value}'>#{label}</option>"
    $(this).append(opt).val(value).mark()

  $.createSelectOption = $.fn.createSelectOption = createSelectOption

  start = ->
    $('body').transformDateSelect()

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

  # Shows and hides info
  $('a.more_info').live('click', ->
    if $(this).hasClass("hide-info")
      #== "Ver información"
      $(this).html("Ocultar información").removeClass("hide-info")
      $( $(this).attr('href') ).show("slow")
    else
      $(this).html("Ver información").addClass("hide-info")
      $( $(this).attr('href') ).hide("slow")
    false
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

  $('.tip').tooltip({
    offset: [-3, 10],
    events: {
      def    : "mouseover,mouseout",
      input  : "focus,blur",
      widget : "focus mouseover,blur mouseout",
      tooltip: ""
    }
  })

  $('ul.menu>li>a').click ->
    false

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
  #checkCR = (evt)->
  #  evt  = evt  = (evt) ? evt : ((event) ? event : null)
  #  node = evt.target || evt.srcElement
  #  if evt.keyCode == 13 and node.type == "text" then false

  #document.onkeypress = checkCR

  start()

)
