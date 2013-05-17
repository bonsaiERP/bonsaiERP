# Present Incomes, Expenses
class ContactBalance
  constructor: (@elem) ->
    @$elem = $(@elem)
    @$incomes = @$elem.find('.incomes')
    @$expenses = @$elem.find('.expenses')
    @data = @$elem.data('data')
  render: ->
    # Render incomes
    @$incomes.append([
      "<div class='b text-success'>Ingresos por cobrar</div>" if @data.incomes.TOTAL,
      @renderDetail(@data.incomes)
    ].join(''))
    # Render expenses
    @$expenses.append([
      "<div class='b text-error'>Egresos por pagar</div>" if @data.expenses.TOTAL,
      @renderDetail(@data.expenses)
    ].join(''))

    @$elem.on('mouseover mouseout', '.detail', (event) =>  @renderCurrencies(event))
  #
  renderDetail: (data) ->
    if data.TOTAL
      html = "#{_b.ntc(data.TOTAL)} #{@currencyLabel(organisation.currency)}"
      html += ' <a href="javascript:;" class="label label-info detail"><i class="icon icon-exchange"></i></a>' unless data[organisation.currency] is data.TOTAL

      html
  #
  renderCurrencies: (event) ->
    switch event.type
      when 'mouseover'
        @showPopover(event)
      when 'mouseout'
        @hidePopover(event)
  #
  showPopover: (event) ->
    if $(event.target).parents('.incomes').length > 0
      @popoverIncomes or= @createPopoverIncomes(event)
      @popoverIncomes.popover('show')
    else
      @popoverExpenses or= @createPopoverExpenses(event)
      @popoverExpenses.popover('show')
  #
  hidePopover: (event) ->
    if $(event.target).parents('.incomes').length > 0
      @popoverIncomes.popover('hide')
    else
      @popoverExpenses.popover('hide')

  createPopoverIncomes: (event) ->
    title = '<span class="text-success b">Detalle ingresos por cobrar</span>'
    html = @createCurrenciesDetail(@data.incomes)

    $(event.target).popover(title: title, html: true, content: html, placement: 'top')
  #
  createPopoverExpenses: (event) ->
    title = '<span class="text-error b">Detalle egresos por pagar</span>'
    html = @createCurrenciesDetail(@data.expenses)

    $(event.target).popover(title: title, html: true, content: html, placement: 'top')
  #
  createCurrenciesDetail: (data) ->
    _.map(data, (v, k) =>
      '<p>' +  _b.ntc(v) + ' ' + @currencyLabel(k) + '</p>' unless k is 'TOTAL'
    ).join('')
  #
  currencyLabel: (cur) ->
    name = currencies[cur].name
    ['<span class="label label-inverse" data-toggle="tooltip" title="', name,'">', cur,'</span>' ].join('')

App.ContactBalance = ContactBalance
