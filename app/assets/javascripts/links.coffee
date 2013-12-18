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
    .html(AjaxLoadingHTML())
    .load($this.attr('href'), (resp, status) ->
      if status is 'error'
        $div.hide('medium')
        $this.show('medium')
        alert 'Exisiton un error'
      else
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
)
