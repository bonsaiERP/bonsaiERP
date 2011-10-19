# Extendig base clases
String::pluralize = ->
  if /[aeiou]$/.test(this)
    return this + "s"
  else
    return this + "es"

# round number
Number::round = (dec)->
  dec = dec || 2
  Math.round(@ * Math.pow(10, dec) ) / Math.pow(10, dec)

# $.browser.msie
# $.browser.version
