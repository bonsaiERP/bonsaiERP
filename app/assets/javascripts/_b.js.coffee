_b = {}
window._b = _b

# Transforms a string date in a default 
_b.dateFormat = (date, format)->
  format = format || $.datepicker._defaults.dateFormat
  if date
    d = $.datepicker.parseDate('yy-mm-dd', date )
    $.datepicker.formatDate($.datepicker._defaults.dateFormat, d)
  else
    ""

currency = {'separator': ",", 'delimiter': '.', 'precision': 2}
_b.currency = currency
# ntc similar function to Ruby on rails number_to_currency
# @param [String, Decimal, Integer] val
ntc = (val, precision)->
  precision = if precision >= 0 then precision else _b.currency.precision

  val = if typeof val == 'string' then (1 * val) else val

  if val < 0 then sign = "-" else sign = ""
  val = val.toFixed(precision)
  vals = val.toString().replace(/^-/, "").split(".")
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

  t = arr.reverse().join(_b.currency.delimiter)
  if tmp != ""
    sep = if t.length > 0 then _b.currency.delimiter else ""
    t = tmp + sep + t

  if precision == 0
    sign + t
  else
    sign + t + _b.currency.separator + vals[1]
# Set the global variable
_b.ntc = ntc

# presents the dimesion in bytes
toByteSize = (bytes)->
  switch true
    when bytes < 1024 then bytes + " bytes"
    when bytes < Math.pow(1024, 2) then roundVal( bytes/Math.pow(1024, 1) ) + " Kb"
    when bytes < Math.pow(1024, 3) then roundVal( bytes/Math.pow(1024, 2) ) + " MB"
    when bytes < Math.pow(1024, 4) then roundVal( bytes/Math.pow(1024, 3) ) + " GB"
    when bytes < Math.pow(1024, 5) then roundVal( bytes/Math.pow(1024, 4) ) + " TB"
    when bytes < Math.pow(1024, 6) then roundVal( bytes/Math.pow(1024, 5) ) + " PB"
    else
      roundVal( bytes/ Math.pow(1024, 6)) + " EB"

# Set the global variable
_b.tobyteSize = toByteSize

_b.notEnter = (event)->
  ( event.type == "keyup" or event.type == "keypress" ) and event.keyCode != 13
