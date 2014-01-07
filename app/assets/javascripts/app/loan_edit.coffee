class LoanEdit
  constructor: (@id) ->
    @$date = $('#edit-date')
    @$due_date = $('#edit-due_date')
    @$description = $('#edit-description')

    @setEvents()
  #
  setEvents: ->
    self = @
    @$description.click (event) -> self.editDescription(event, this)
  #
  editDescription: (event, elem) ->
    self = @
    $html = $(templateDescription)
    $elem = $(elem)
    val = $elem.siblings('.data').text()
    $parent = $elem.parents('.edit-loan')
    $parent.hide()
    $html.insertAfter($parent)
    $html.find('textarea').val(val)

    $html.on 'click', '.cancel', ->
      $parent.show()
      $html.remove()

    $html.on 'click', '.btn-primary', ->
      self.update({ description: $html.find('textarea').val() }, $html, $parent)

  #
  update: (attrs, $html, $parent) ->
    $.ajax(
      method: 'patch'
      data: attrs
      url: "/loans/#{@id}"
    )
    .done(resp) ->
      if resp.success
        val = attrs.description || attrs.date || attrs.due_date
        $html.remove()
        $parent.find('.data').text



App.LoanEdit = LoanEdit

templateDate = """
"""

templateDescription = """
<div>
  <textarea cols="50" rows="5"></textarea>
  <div>
    <button class="btn btn-primary btn-small">Salvar</button>
    <button class="btn btn-small cancel">Cancelar</button>
  </div>
</div>
"""
