$(->
  createCancelButton = ($div, $link) ->
    $cancel = $('<a class="btn">Cancelar</a>').click( ->
      $div.html('').hide('medium')
      $link.show('medium')
    )
    $div.find('.form-actions').append($cancel)

  $('body').on('click', 'a[data-target]', (event) ->
    event.preventDefault()
    $this = $(this)
    $this.hide('medium')
    $div = $($this.data('target'))
    $div.addClass('ajax-modal').data('link', $this)
    .show('medium')
    #.html(AjaxLoadingHTML())
    $.get($this.attr('href'), (resp, status) ->
      if status is 'error'
        $div.hide('medium')
        $this.show('medium')
        alert 'Exisiton un error'
      else
        if $div.attr('ng-controller')
          $scope= $div.scope()
          console.log $scope
          $scope.$apply (scope) -> scope.htmlContent = resp
        else
          $div.html(resp)

        $div.setDatepicker()
        createCancelButton($div, $this)
    )
    $div.on 'reload:ajax-modal', ->
      createCancelButton($div, $this)
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
        $check.prop('checked', false)
        $row.removeClass('selected')
      else
        $check.prop('checked', true)
        $row.addClass('selected')

    )

  $.rowCheck = $.fn.rowCheck = rowCheck


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
      elem: $this.data('elem'),
      width: $this.data('width') || 800,
      # Return response instead of calling default
      return: $this.data('return')
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
)
