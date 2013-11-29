$(->
  $('body').on('click', 'a[data-target]', (event) ->
    event.preventDefault()
    $this = $(this)
    $this.hide('medium')
    console.log $this.data('target'), $this
    $($this.data('target')).load($this.attr('href'))
  )
)
