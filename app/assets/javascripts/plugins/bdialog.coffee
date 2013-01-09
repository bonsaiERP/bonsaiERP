@bdialog =
  defaultOptions:
    loadingText: 'Cargando'

# Class to control dialogs with options for select and other stuff
# when updating forms
class @Bdialog
  loadingText: bdialog.defaultOptions.loadingText
  loadingHTML: """
  <h4 class='c'><i class='icon-spinner icon-spin icon-large'></i> #{@loadingText}</h4>
  """
  #
  constructor: (params) ->
    data = params || {}
    params = _.extend({
      'title': '', 'width': 800, 'modal': true, 'resizable' : false, 'position': 'top'
    }, params)

    html = params['html'] || @loadingHTML
    div_id = params.id
    css = "ajax-modal " + params['class'] || ""
    @$dialog = $('<div/>').attr( { 'id': params['id'], 'title': params['title'] } )
    .html(html)
    .data(data)
    .addClass(css)
    .css({'z-index': 10000 })

    delete(params['id'])
    delete(params['title'])

    @$dialog.dialog(params)

    @$dialog
  #
  updateRelated: ->
