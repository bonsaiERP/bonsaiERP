# Plugin to create tours similar to jquery.joyride
class Bride
  nubPos: 'top'
  defaults:
    tipLocation: 'top'
    tipWidth: 300
  #
  constructor: (@listSel) ->
    $('.joyride-close-tip').trigger('click')
    @$list = $(@listSel)
    @pos = 0
    @$items = @$list.find('li')
    @setTip()
    @setEvents()
  #
  setTip: ->
    @$tip = $(template).css({position: 'absolute', display: 'block', visibility: 'hidden'})
    .appendTo('body')
  #
  init: (options) ->
    @showPos(0)
  #
  showPos: (pos) ->
    if @$items[pos]
      @setStepCssClass(pos)
      @$current = $(@$items[pos])
      @pos = pos + 1
      @show()
    else
      @hide()
  #
  setStepCssClass: (pos) ->
    switch
      when pos is 0
        @$tip.addClass('first-step')
      when @$items.length is (pos - 1)
        @$tip.addClass('last-step')
      else
        @$tip.removeClass('first-step').removeClass('last-step')

  #
  hide: ->
    @$tip.css({visibility: 'hidden'})
  #
  show: ->
    tipLocation = @$current.data('tipLocation') || @defaults.tipLocation
    name = @$current.data('name') || "#{@listSel}-#{@pos}"
    @$tip.css({visibility: 'visible', top: '100px'}).data({pos: @pos})
    .attr({'data-name': name}).find('#content').html(@$current.html())

    @$tip.find('.joyride-nub').attr('class', '').addClass("joyride-nub #{tipLocation}")
    @$tip.find('.next').text(@$current.data('text'))

    @setPosition()
  #
  setPosition: ->
    @$tip
    $el = $(@$current.data('sel'))
    options = _.merge({}, @$current.data('options'))
    position = $el.position()
    w = $el.width()
    h = $el.height()
    x = options.x or @getX(position.left, w)
    y = options.y or @getY(position.top, h)
    @$tip.css(top: y, left: x)
  #
  getX: (x, w) ->
    switch
      when @$tip.find('.joyride-nub').hasClass('left')
        x + w + 30
      when @$tip.find('.joyride-nub').hasClass('right')
        x - 300 - 30
      else
        x + 10
  #
  getY: (y, h) ->
    th = @$tip.height()
    speed = 400

    switch
      when @$tip.find('.joyride-nub').hasClass('top')
        $('body').scrollTo(y, speed)
        y + h + 30
      when @$tip.find('.joyride-nub').hasClass('bottom')
        $('body').scrollTo(y - h - th - 30, speed)
        y - th - 20
      else
        $('body').scrollTo(y - 20, speed)
        y - 20
  #
  setEvents: ->
    @$tip.on 'click', '.next', =>
      @showPos @$tip.data('pos')

    @$tip.on 'click', '.prev', =>
      @showPos @$tip.data('pos') - 2

    @$tip.on 'click', '.joyride-close-tip', =>
      @hide()
  #
  getElementPosition: (el) ->

Plugins.Bride = Bride

template = """
<div class="joyride-tip-guide" data-index="0" style="visibility: visible; display: block; top: 50px; left: 50px;">
  <span class="joyride-nub"></span>
  <div class="joyride-content-wrapper" role="dialog">
    <div id="content"></div>
    <a href="javascript:;" class="joyride-next-tip prev">Anterior</a>
    <a href="javascript:;" class="joyride-next-tip next"></a>
    <a href="javascript:;" class="joyride-close-tip">X</a>
  </div>
</div>
"""
