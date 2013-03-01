# Manages remotes methods
# Test on console: new AjaxRemote($('[data-remote]:not([data-method])').get(0))
class AjaxRemote
  constructor: (elem, event) ->
    @$this = $(elem)
    @url = @$this.attr('href')

    switch @$this.attr('data-method')
      when 'post', 'POST'
        @post()
      when 'delete', 'DELETE'
        @delete()
      when 'put', 'PUT'
        @put()
      else
        @get()
  #
  get: ->
    urls = @url.split('?')
    urls[0] = if urls[0].match(/.+\.js$/) then urls[0] else urls[0] + ".js"
    $.get(urls.join('?'))
  #
  delete: ->
    @$parent = @$this.parents("tr:first, li:first")
    @$parent.addClass('marked')

    conf = @$this.data('confirm') || 'Are you sure that you want to delete the selected element'

    if confirm(conf)
      @deleteItem()
    else
      @$parent.removeClass 'marked'
  #
  deleteItem: ->
    $.ajax(
      'url': @url
      type: 'delete'
    )
    .success (resp) =>
      @$parent.remove()
      $('body').trigger('ajax:delete', @url)
    .error ->
      alert 'Existio un error al borrar'
    .complete =>
      @$parent.removeClass 'marked'

Plugin.AjaxRemote = AjaxRemote

jQuery(->
  $('body').on('click', '[data-remote]', (event) ->
    event.preventDefault()
    new AjaxRemote(this)
    false
  )
)
