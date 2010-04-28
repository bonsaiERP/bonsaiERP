# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
#    inflect.plural /$/, 's'
#    inflect.plural /([^aeioué])$/, '\1es'
#    inflect.plural /([aeiou]s)$/, '\1'
#    inflect.plural /z$/, 'ces'
#    inflect.plural /á([sn])$/, 'a\1es'
#    inflect.plural /í([sn])$/, 'i\1es'
#    inflect.plural /ó([sn])$/, 'o\1es'
#    inflect.plural /ú([sn])$/, 'u\1es'
    #inflect.plural(/^(\w+)\s(.+)$/, lambda { |match|  head, tail = match.split(/\s+/, 2)"#{head.pluralize} #{tail}"})
#  inflect.plural /^(ox)$/i, '\1en'
#  inflect.singular /^(ox)en/i, '\1'
   inflect.singular 'taxes', 'tax'
#  inflect.irregular 'person', 'people'
#  inflect.uncountable %w( fish sheep )
end
