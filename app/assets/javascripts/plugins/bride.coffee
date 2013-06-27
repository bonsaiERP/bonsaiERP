# Plugin to create tours similar to jquery.joyride
class Bride
  nubPos: 'top'
  defaults:
    tipLocation: 'top'
    tipWidth: 300
  #
  constructor: (el) ->
    $('.joyride-close-tip').trigger('click')
    @$list = $(el)
    @pos = 0
    @$items = @$list.find('li')
    @setTip()
    @setEvents()
    #$('body').animate({scrollTop: '50px'})
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
      @$current = $(@$items[pos])
      @pos = pos + 1
      @show()
    else
      @hide()
  #
  hide: ->
    @$tip.css({visibility: 'hidden'})
  #
  show: ->
    tipLocation = @$current.data('tipLocation') || @defaults.tipLocation
    @$tip.css({visibility: 'visible', top: '100px'}).data('pos', @pos)
    .find('#content').html(@$current.html())
    @$tip.find('.joyride-nub').attr('class', '').addClass("joyride-nub #{tipLocation}")
    @$tip.find('.joyride-next-tip').text(@$current.data('text'))

    @setPosition()
  #
  setPosition: ->
    @$tip
    $el = $(@$current.data('sel'))
    position = $el.position()
    w = $el.width()
    h = $el.height()
    x = @getX(position.left, w)
    y = @getY(position.top, h)
    @$tip.css(top: y, left: x)
  #
  getX: (x, w) ->
    switch
      when @$tip.find('.joyride-nub').hasClass('left')
        x + w + 20
      when @$tip.find('.joyride-nub').hasClass('right')
        x - 300 - 20
      else
        x + 10
  #
  getY: (y, h) ->
    th = @$tip.height()
    switch
      when @$tip.find('.joyride-nub').hasClass('top')
        y + h + 20
      when @$tip.find('.joyride-nub').hasClass('bottom')
        y - th - 10
      else
        y - 20
  #
  setEvents: ->
    @$tip.on 'click', '.joyride-next-tip', =>
      @showPos @$tip.data('pos')

    @$tip.on 'click', '.joyride-close-tip', =>
      @hide()
  #
  getElementPosition: (el) ->
  #
  scroll: ->

Plugin.Bride = Bride

template = """
<div class="joyride-tip-guide" data-index="0" style="visibility: visible; display: block; top: 50px; left: 50px;">
  <span class="joyride-nub"></span>
  <div class="joyride-content-wrapper" role="dialog">
    <div id="content"></div>
    <a href="#" class="joyride-next-tip"></a>
    <a href="javascript:;" class="joyride-close-tip">X</a>
  </div>
</div>
"""
