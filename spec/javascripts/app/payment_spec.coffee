#= require jquery
#= require namespace
#= require plugins/_b
#= require libraries/lodash
#= require libraries/backbone
#= require libraries/rivets
#= require app/payment

describe "Payment class methods", ->
  it "paymentOptions", ->
    val = {type: 'Cash', amount: 10.5, to_s: 'Caja 1', currency: 'BOB'}

    expect( App.Payment.paymentOptions(val) ).toEqual('<span class="label">Caja</span> Caja 1 <span class="label label-inverse">BOB</span>')

    val = {type: 'Income', amount: 10.5, to_s: 'Ingreso 1', currency: 'BOB'}

    expect( App.Payment.paymentOptions(val) ).toEqual('<span class="label">Ingreso</span> Ingreso 1 <span class="muted"> Saldo:</span> <span class="balance">10,50</span> <span class="label label-inverse">BOB</span>')


@currency = "BOB"
fixture.preload('payment_form.html', "test.json")
@fix = ''

describe "Payment instance", ->

  beforeEach ->
    @fixtures = fixture.load('payment_form.html', 'test.json', true)

  it "1", ->
    $('body').append($(fixture.el).html())
    p = new App.Payment
    @fix = fixture.el

    setTimeout( ->
      rivets.bind($('#income-payment-form'), {payment: p})
      p.set('amount', 10)
      expect(true).toBe(false)
    , 200)
    console.log(fixture.el)

  it "2", ->
    console.log 2
