COUNTRIES = Hash[
  YAML.load_file(Rails.root.join('db', 'defaults', 'countries.yml')).map {|v| [v[:code], v] }
]

