Color = {
  componentToHex: (c) ->
    hex = c.toString(16)
    hex.length == 1 ? "0" + hex : hex
  #
  rgbToHex: (r, g, b) ->
    "#" + componentToHex(r) + componentToHex(g) + componentToHex(b)
  # Conver Hex to RGB
  hexToRgb: (hex) ->
    result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    if result
      {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      }
    else
      null
  # Function to determine background colors
  idealTextColor: (bgColor) ->

    nThreshold = 105
    components = @hexToRgb(bgColor)
    bgDelta = (components.r * 0.299) + (components.g * 0.587) + (components.b * 0.114)

    if ((255 - bgDelta) < nThreshold) then "#000000" else "#ffffff"
}

@Plugin.Color = Color
