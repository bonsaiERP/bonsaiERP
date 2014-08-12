$(->
  # Creates cancel button for data-target or other
  createCancelButton = ($div, $link) ->
    return  if $div.find('.cancel').length > 0

    $cancel = $('<a/>', {
      class: 'btn cancel', href: 'javascript:;', text: 'Cancelar'
      click: ->
        if $div.attr('ng-controller')
          $scope = $div.scope()
          $scope.$apply (scope) ->
            scope.htmlContent = ''
            scope.$$childHead = null
            scope.$$childTail = null
        else
          $div.html('').hide('medium')

        $link.show('medium')
    })

    $div.find('.form-actions').append($cancel)

  ########################################
  # Hide container for data target
  getHideCont = ($this) ->
    if target = $this.data('targethide')
      if target.$jquery then target else $(target)
    else
      $this

  # Creates a data target loaded via AJAX
  # data-target
  $('body').on('click', 'a[data-target]', (event) ->
    return  if $(this).data('toggle') # Prevent data toggle modal

    event.preventDefault()
    $this = $(this)
    $hide = getHideCont($this)
    $hide.hide('medium')
    $div = $($this.data('target'))
    $div.addClass('ajax-modal').data('link', $this)

    if $div.attr('ng-controller')
      $scope = $div.scope()
      $scope.$apply (scope) ->
        scope.$$childHead = null
        scope.$$childTail = null
        scope.htmlContent = AjaxLoadingHTML()
    else
      $div.show('medium').html(AjaxLoadingHTML())

    $.get($this.attr('href'), (resp, status, jqXHR) ->
      if status is 'error'
        $div.hide('medium')
        $this.show('medium')
        $('.top-left').notify({
          type: 'error',
          message: { text: 'Exisiton un error' }
        }).show()

      else
        if $div.attr('ng-controller')
          $scope = $div.scope()
          $scope.$apply (scope) ->
            scope.$$childHead = null
            scope.$$childTail = null
            scope.htmlContent = resp
        else
          $div.html(resp)

        $div.setDatepicker()
        createCancelButton($div, $hide)
    )
    $div.on 'reload:ajax-modal', ->
      createCancelButton($div, $hide)
  )

  # Marks a row adding a selected class to the row
  rowCheck = ->
    $(this).on('click', '>li,>tr', (event) ->
      target = event.target
      $target = $(target)

      return true  if $target.get(0).tagName is 'A' or $target.parent('a').length > 0

      $check = $(this).find('input.row-check')
      $row = $check.parents('tr,li')

      if target.type is 'checkbox' and $(target).hasClass('row-check')
        if $check.prop('checked')
          $row.addClass('selected')
        else
          $row.removeClass('selected')

        return true

      if $check.prop('checked')
        $check.trigger('click')
        $row.removeClass('selected')
      else
        $check.trigger('click')
        $row.addClass('selected')

    )

  $.rowCheck = $.fn.rowCheck = rowCheck

  $('.has-row-check').rowCheck()

  ########################################
  # Presents any link url in a modal dialog and loads with AJAX the url
  $('body').on('click', 'a.ajax', (event) ->
    event.preventDefault()

    id = new Date().getTime().toString()
    $this = $(this)
    $this.data('ajax_id', id)

    $div = createDialog({
      title: $this.data('title'),
      # Elem related with the call input, select, etc
      elem: $this.data('elem') || $this,
      width: $this.data('width') || 800,
      #dialogClass: $this.data('class') || 'normal-dialog',
      # Return response instead of calling default
      return: $this.data('return') || true
    })

    $div.load( $this.attr("href"), (resp, status, xhr, dataType) ->
      $this = $(this)

      if $div.attr('ng-controller')
        $div.scope().htmlContent = resp
      else
        $div = $('<div>').html(resp)

      $this.find('.form-actions').append('<a class="btn cancel" href="javascript:;">Cancelar</a>')

      $tit = $this.dialog('widget').find('.ui-dialog-title')
      .text($div.find('h1').text())

      $div.setDatepicker()
    )
    event.stopPropagation()
  )

  ########################################
  # Replace jquery_ujs

  # Creates a form fot the url
  getFormLink = (action, method, params = {}) ->
    html = "<input type='hidden' name='utf-8' value='&#x2713;' />"
    html += "<input type='hidden' name='authenticity_token' value='#{csrf_token}' />"
    html += "<input type='hidden' name='_method' value='#{method}' />"

    $('<form/>').attr({'method': 'post', 'action': action })
    .html(html).appendTo('body')


  # Method to remove rows
  deleteRow = ($link, url, confCallback) ->
    $parent = $link.parents('tr:first, li:first')
    $parent.addClass('marked')

    if confCallback.call @
      $.ajax(
        'url': url
        'type': 'delete'
      )
      .done( (resp) ->
        if resp['destroyed?']
          $link.trigger('ajax:delete', $link)
          $('body').trigger('ajax:delete', [url, $link])
          $parent.remove()
        else
          $parent.removeClass('marked')
          alert "El registro no puede ser eliminado debe tener relaciones."
      )
      .fail -> alert('Existion un error al borrar')

    else
      $parent.removeClass('marked')

  # Get the confirmation message
  getConfirmMessage = ($this) ->
    switch
      when $this.data('confirm')
        $this.data('confirm')
      when $this.data('method') is 'delete' and $this.data('remote')
        'Esta segur@ de eliminar el registro?'
      when $this.data('method') is 'delete'
        'Esta segur@ de eliminar el registro?'
      else
        null

  # call remote xhr AJAX
  callUrlRemoteMethod = ($link, confCallback) ->
    url = $link.attr('href') or $this.data('href') or $this.data('url')

    if ($link.parents('tr') or $link.parents('li')) and $link.data('method') is 'delete'
      return deleteRow $link, url, confCallback

    if confCallback.call @
      switch $link.data('method')
        when 'post'
          $.post url
        when 'put'
          $.put url
        when 'patch'
          $.patch url
        when 'delete'
          $.delete url
        else
          $.get url


  # Call using a form
  callUrlMethod = ($link, confCallback) ->
    url = $link.attr('href') or $this.data('href') or $this.data('url')
    method = $link.data('method')

    if confCallback.call @
      getFormLink(url, method).submit()


  # Check the methods to call the url
  $('body').on 'click', '[data-method]', (event) ->

    event.preventDefault()

    $this = $(this)
    method = $this.data('method') || 'get'
    callbackMessage = getConfirmMessage($this)

    confirmCallback = ->
      if callbackMessage
        confirm callbackMessage
      else
        true

    if $this.data('remote')
      callUrlRemoteMethod($this, confirmCallback)
    else
      callUrlMethod($this, confirmCallback)
)
