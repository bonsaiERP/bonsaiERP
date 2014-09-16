# Manages remotes methods
# Test on console: new AjaxRemote($('[data-remote]:not([data-method])').get(0))
class DataMethod
  constructor: (event, elem) ->
    @$this = $(elem)
    @url = @$this.attr('href')

    switch @$this.attr('data-method')
      when 'post', 'POST'
        @post()
      when 'delete', 'DELETE'
        @delete()
      when 'put', 'PUT'
        @put()
      when undefined, ''
        @get()
      else
        throw @$this.attr('data-method') + " data-method not found"
  #
  delete: ->
    msg = if @$this.data('confirm') then @$this.data('confirm') else conf = 'Are you sure to delete the selected item'
    return false  unless confirm(msg)

    html = """
    <input name="utf8" type="hidden" value="✓">
    <input name="authenticity_token" type="hidden" value="#{csrf_token}">
    <input type="hidden" name="_method" value="delete" />
    """
    $('<form/>')
    .attr(action: @$this.attr('href'), method: 'post')
    .html(html).submit()

class AjaxRemote extends DataMethod
  #
  get: ->
    urls = @url.split('?')
    urls[0] = if urls[0].match(/.+\.js$/) then urls[0] else urls[0] + ".js"
    $.get(urls.join('?'))
  #
  delete: ->
    @$parent = @$this.parents("tr:first, li:first")
    @$parent.addClass('marked')

    msg = if @$this.data('confirm') then @$this.data('confirm') else conf = 'Are you sure to delete the selected item'

    if confirm(msg)
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
      if resp['destroyed?'] or resp['success']
        @$parent.remove()
      $('body').trigger('ajax:delete', @url)
    .error ->
      alert 'There was an error deleting'
    .complete =>
      @$parent.removeClass 'marked'

Plugin.AjaxRemote = AjaxRemote

jQuery( ->
  $('body').on('click', '[data-remote]', (event) ->
    event.preventDefault()
    new AjaxRemote(event, this)
  )
  $('body').on('click', '[data-method]', (event) ->
    event.preventDefault()
    $this = $(this)
    if not($this.data('remote')) and not $this.hasClass('ajax')
      new DataMethod(event, this)
  )
)
