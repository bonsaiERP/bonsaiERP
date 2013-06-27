class Bride
  nubPos: 'top'
  defaults:
    tipLocation: 'top'
  #
  constructor: (el) ->
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
      @pos += 1
      @show()
    else
      @hide()
  #
  hide: ->
    @$tip.css({visibility: 'hidden'})
  #
  show: ->
    options = _.merge({}, @defaults, @$current.data('options'))
    console.log options, @$current.data('options')
    @$tip.css({visibility: 'visible', top: '100px'}).data('pos', @pos)
    .find('#content').html(@$current.html())
    @$tip.find('.joyride-nub').attr('class', '').addClass("joyride-nub #{options.tipLocation}")
    @$tip.find('.joyride-next-tip').text(@$current.data('text'))
  #
  setEvents: ->
    @$tip.on 'click', '.joyride-next-tip', =>
      @showPos @$tip.data('pos')
  #
  getElementPosition: (el) ->
  #
  scroll: ->

Plugin.Bride = Bride

template = """
<div class="joyride-tip-guide" data-index="0" style="visibility: visible; display: block; top: 250px; left: 200.5px;">
  <span class="joyride-nub"></span>
  <div class="joyride-content-wrapper" role="dialog">
    <div id="content"></div>
    <a href="#" class="joyride-next-tip"></a>
    <a href="#close" class="joyride-close-tip">X</a>
  </div>
</div>
"""
