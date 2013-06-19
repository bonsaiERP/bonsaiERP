Tag = {
  formatResult: (data) ->
    color = Plugin.Color.idealTextColor(data.bgcolor)

    ['<span class="btag" style="background-color:', data.bgcolor,
      ';color:', color, ';">', data.text, '</span>'
    ].join('')
  #
  formatSelect: (data) ->
    color = Plugin.Color.idealTextColor(data.bgcolor)
    console.log color

    ['<span class="btag" style="background-color:', data.bgcolor,
      ';color:', color, ';">',
      '<a class="icon-remove" href="javascript:;" style="color:', color,'"></a> ',
      data.text, '</span>'
    ].join('')
}

Plugin.Tag = Tag
