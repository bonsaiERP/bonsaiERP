class Report
  incColor: '#77b92d'
  expColor: '#db0000'
  data: {}
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
  # Parses data and creates graph
  createGraph: ->
    $.plot(@sel,
      [
        {label: 'Inresos', data: @parseData(@incomes), color: @incColor},
        {label: 'Egresos', data: @parseData(@expenses), color: @expColor}
      ],
    @options)
  #
  parseData: (data) ->
    _.map(data, (v) ->
      d = v.date.split('-')
      d[1] = d[1] * 1 - 1
      t = new Date(d[0], d[1], d[2]).getTime()
      [t, v.tot * 1]
    )

App.Report = Report
