@Currency = {
  name: (code) ->
    currencies[code].name
  label: (code) ->
    "<span class='label label-inverse' title='#{@name(code)}' rel='tooltip'>#{code}</span>"
}
