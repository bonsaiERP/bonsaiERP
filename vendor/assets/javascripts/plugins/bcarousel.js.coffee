# Carousel based on twitter-bootstrap
# @creator: Boris Barroso
# @email: boriscyber@gmail.com
class Bcarousel
  constructor: (@container, @width)->
    @$container = $(@container)
    @$container.css( overflow: "hidden", width: "#{@width}px")

    @$inner     = @$container.find(".carousel-inner")
    @$left      = @$container.find(".left")
    @$right     = @$container.find(".right")

    @offset = 0
    @size   = @$container.find(".item").length
    @last   = @width * @size - @width

    @$inner.css( width: "#{@width * @size}px" )
    @$left.hide()

    @.setEvents()
  # Events
  setEvents: ->
    @$right.click => @.move("right")
    @$left.click => @.move("left")

  # Move
  move: (to)->
    return false unless @.shouldMove()

    sign = if to == "left" then 1 else -1
    @offset = @offset + sign * @width

    @$inner.animate( marginLeft: "#{@offset}px" )

    @.showHideMovers()
  # Should move
  shouldMove: (to)->
    switch
      when(to == "right" and @offset == -@last)
        false
      when(to == "left" and @offset == 0)
        false
      else
        true
  # Show hide
  showHideMovers: ->
    if @offset == -@last
      @$right.hide()
    else
      @$right.show()

    if @offset == 0
      @$left.hide()
    else
      @$left.show()

(($)->
  $.fn.bcarousel = (width)->
    new Bcarousel(this, width)
)(jQuery)
