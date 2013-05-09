class GraphReport
  incColor: '#77b92d'
  expColor: '#db0000'
  data: {}
  prevX: false
  prevY: false
  options: {
    series: {
      lines: {show: true},
      points: {show: true}
    },
    grid: {
      hoverable: true
      tickColor: '#F5F5F5'
    },
    legend: {
      show: false,
    }
    xaxis: {
      mode: 'time'
      timeformat: '%m/%d'
    }
  }

  #
  constructor: (@sel, @incomes, @expenses) ->
    @createGraph()
    @createTooltip()
  # Parses data and creates graph
  createGraph: ->
    $.plot(@sel,
      [
        {label: 'Inresos', data: @parseData(@incomes), color: @incColor},
        {label: 'Egresos', data: @parseData(@expenses), color: @expColor}
      ],
    @options)
  #
  createTooltip: ->
    @tipID = 'tooltip-' + new Date().getTime()
    @$tooltip = $("<span id='#{@tipID}'></span>")
    .css({
      position: 'absolute', border: '1px solid gray', background: 'rgba(0,0,0, 0.8)', fontSize: '13px',
      top: '100px', left: '10px', color: '#FFF', padding: '4px 8px', zIndex: 10000, borderRadius: '3px'
    }).hide().prependTo('body')

    @setTooltipEvent()
  #
  setTooltipEvent: ->
    self = this
    $('body').on('plothover', @sel, (event, pos, item) ->
      if(item)
        if self.prevX isnt item.pageX || self.prevY isnt item.pageY
          date = $.datepicker.formatDate(bonsai.dateFormat, new Date(item.datapoint[0]))

          self.$tooltip.css({left: (item.pageX - 30) + 'px', top: ( item.pageY - 40 ) + 'px' })
          .html('<i>' + date + '</i>: ' + _b.ntc(item.datapoint[1]) + ' ' + bonsai.currency)
          self.prevX = item.pageX
          self.prevY = item.pageY

        self.$tooltip.show()
      else
        self.$tooltip.hide()
    )
  #
  parseData: (data) ->
    _.map(data, (v) ->
      d = v.date.split('-')
      d[1] = d[1] * 1 - 1
      t = new Date(d[0], d[1], d[2]).getTime()
      [t, v.tot * 1]
    )

App.GraphReport = GraphReport
