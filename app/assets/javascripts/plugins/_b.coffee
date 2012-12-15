_b = {
  numSeparator: ','
  numDelimiter: '.'
  numPresicion: 2
  #
  dateFormat: (date, format) ->
    format = format || $.datepicker._defaults.dateFormat
    if date
      d = $.datepicker.parseDate('yy-mm-dd', date )
      $.datepicker.formatDate($.datepicker._defaults.dateFormat, d)
    else
      ""
  # Returns the value with decimals
  roundVal: (val, dec) ->
    dec ||= 0
    if dec == 0
      Math.round(val)
    else
      Math.round(val * Math.pow(10, dec)) / Math.pow(10, dec)

  # ntc similar function to Ruby on rails number_to_currency
  # @param [String, Decimal, Integer] val
  ntc: (val, precision) ->
    precision = if precision >= 0 then precision else @numPresicion

    val = if typeof val == 'string' then (1 * val) else val

    if val < 0 then sign = "-" else sign = ""

    vals = val.toFixed(precision).replace(/^-/, "").split(".")
    val = vals[0]
    l = val.length - 1
    ar = val.split("")
    arr = []
    tmp = ""
    c = 0
    for i in [l..0]
      tmp = ar[i] + tmp
      if (l - i + 1)%3 == 0 and i < l
        arr.push(tmp)
        tmp = ''
      c++

    t = arr.reverse().join(@numDelimiter)
    if tmp != ""
      sep = if t.length > 0 then @numDelimiter else ""
      t = tmp + sep + t

    if precision == 0
      sign + t
    else
      sign + t + @numSeparator + vals[1]
  # Set the global variable

  # presents the dimesion in bytes
  toByteSize: (bytes, dec) ->
    dec ||= @numPresicion
    switch true
      when bytes < 1024 then bytes + " bytes"
      when bytes < Math.pow(1024, 2) then @ntc( bytes/Math.pow(1024, 1) ) + " Kb"
      when bytes < Math.pow(1024, 3) then @ntc( bytes/Math.pow(1024, 2) ) + " MB"
      when bytes < Math.pow(1024, 4) then @ntc( bytes/Math.pow(1024, 3) ) + " GB"
      when bytes < Math.pow(1024, 5) then @ntc( bytes/Math.pow(1024, 4) ) + " TB"
      when bytes < Math.pow(1024, 6) then @ntc( bytes/Math.pow(1024, 5) ) + " PB"
      else
        roundVal( bytes/ Math.pow(1024, 6)) + " EB"

  notEnter: (event) ->
    ( event.type == "keyup" or event.type == "keypress" ) and event.keyCode != 13
}

window._b = _b
