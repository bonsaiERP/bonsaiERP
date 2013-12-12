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
)
