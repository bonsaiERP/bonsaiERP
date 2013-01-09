CURRENCIES = Hash[
  YAML.load_file(Rails.root.join('db', 'defaults', 'currencies.yml')).map {|v| [v[:code], v]}
]

CURRENCY_KEYS = CURRENCIES.keys
