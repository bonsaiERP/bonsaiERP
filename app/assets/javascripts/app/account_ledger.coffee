class AccountLedgerReference
  constructor: (@link) ->
    @$link = $(@link)
    @$cont = @$link.parents('.edit-reference')
    @$row = @$link.parents('.account_ledger')

    @$form = $(_.template(template, reference: @$link.data('reference')) )
    @setEvents()
  #
  setEvents: ->
    @$form.on('submit', (event) =>
      event.preventDefault()
      @$form.find('.btn-primary').prop('disabled', true).text('Salvando...')
      @save()
    )
    @$form.on('click', 'a.cancel', =>
      @$cont.show()
      @$form.remove()
    )

    @$form.insertAfter(@$cont)
    @$cont.hide()
  #
  save: ->
    self = this
    reference = @$form.find('#reference').val()
    $.ajax({
      url: "/account_ledgers/#{self.$link.data('id')}",
      data: {reference: reference},
      type: 'PUT'
    })
    .done (resp) ->
      self.$row.find('.reference').html(reference.replace(/\n/g, '<br>'))
      $user = self.$row.find('.updater')
      self.$link.data('reference', reference)

      $user.attr('data-original-title', "MODIFICADO por: #{resp.updater} #{resp.updated_at}")  if $user.length > 0
      self.$cont.show()
      self.$form.remove()
      self.$row.trigger('ledger-reference:update', [resp])
    .fail ->
      txt = @$row.find('.code').text()
      alert 'Exisitio un error al actualizar la referencia de' + txt

$(->
  $('body').on('click', '.account_ledger .edit-ledger-reference-link', ->
    new AccountLedgerReference(this)
  )
)

template = """
<form>
  <textarea id='reference' rows='3' cols='35'>[:reference:]</textarea>
  <div class='clearfix'></div>
  <button class='btn btn-small btn-primary' title='Actualizar referencia'>Act. referencia</button>
  <a class='btn btn-small cancel'>Cancelar</a>
</form>
"""

App.AccountLedgerReference = AccountLedgerReference
