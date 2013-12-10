$(->
  $('body').on('click', 'a[data-target]', (event) ->
    event.preventDefault()
    $this = $(this)
    $this.hide('medium')
    $div = $($this.data('target'))
    $div.addClass('ajax-modal')
    .show('medium')
    .html(AjaxLoadingHTML())
    .load($this.attr('href'), (resp, status) ->
      if status is 'error'
        $div.hide('medium')
        $this.show('medium')
        alert 'Exisiton un error'
      else
        $div.setDatepicker()
        $cancel = $('<a class="btn">Cancelar</a>').click( ->
          $div.html('').hide('medium')
          $this.show('medium')
        )
        $div.find('.form-actions').append($cancel)
    )
  )
)
