class @ModalManager
  template: """
  <div id="{{modalId}}" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-toggle="modal">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
      <h3 class="tit">{{title}}</h3>
    </div>
    <div class="modal-body">
      {{body}}
      <h3 class="muted center"><img src="/assets/ajax-loader.gif"/> Loading...</h3>
    </div>
    <div class="modal-footer">
      {{footer}}
    </div>
  </div>
  """
  options:
    backdrop: true
    keyboard: true
    show: true
    remote: false
    toggle: true
  #
  constructor: ->
    @renderer = _.template(@template)
  # Creates a modal dialog with twitter bootstrap
  create: (options = {}) ->
    $('.modal').remove()
    options = _.merge(options, {modalId: new Date().getTime()} )
    @$modal = $(@renderer(
      title: options.title,
      body: options.body,
      footer: options.footer,
      modalId: options.modalId))

    _.each(['title', 'body', 'footer'], (v) -> delete options[v] )

    @$modal.attr(options).modal()
  # Sets the html for the response from the server
  setResponse: (resp) ->
    $resp = $('<div>').append(resp)
    @$modal.find('.modal-header h3').html($resp.find('h1').html())
    @$modal.find('.modal-body').html(resp)
    @$modal.setDatepicker()

    if $resp.find('.form-actions').length > 0
      @setFormActions($resp)
  #
  setFormActions: ($resp) ->
    @$modal.find('.modal-footer').append($resp.find('.form-actions').html())
    @$modal.find('.modal-footer').on('click', 'input:submit', =>
      @$modal.find('form').submit()
    )
