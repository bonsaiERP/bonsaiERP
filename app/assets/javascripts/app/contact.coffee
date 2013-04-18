# Present Incomes, Expenses
class ContactBalance
  constructor: (@elem) ->
    @$elem = $(@elem)
    @$incomes = @$elem.find('.incomes')
    @$expenses = @$elem.find('.expenses')
    @data = @$elem.data('data')
  render: ->
    # Render incomes
    @$incomes.html(@renderDetail(@data.incomes))
    # Render expenses
    @$expenses.html(@renderDetail(@data.expenses))
  renderDetail: (data) ->
    if data.TOTAL
      "TOTAL: #{@currencyLabel(organisation.currency)} #{_b.ntc(data.TOTAL)}"
    else
      ""
  currencyLabel: (cur) ->
    name = currencies[cur].name
    ['<span class="label label-inverse" data-toggle="tooltip" title="', name,'">', cur,'</span>' ].join('')

App.ContactBalance = ContactBalance
