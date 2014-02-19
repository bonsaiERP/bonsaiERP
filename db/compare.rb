require 'sequel'
require 'benchmark'
require 'ffaker'
# adapter://user:password@host/database
DB = Sequel.connect('postgres://demo:demo123@localhost/test')

# Create all data
sql = "CREATE table names (name_btree text, name_gin text)"
DB.execute sql
sql = "CREATE EXTENSION pg_trgm"
DB.execute sql
sql = "CREATE INDEX index_gin ON names (name_btree)"
DB.execute sql
sql = "CREATE INDEX index_gin ON names USING gin (name_gin gin_trgm_ops)"
DB.execute sql

names = DB[:names]
puts 'Creating'
puts Benchmark.measure do
  arr = 1_000_000.times.map { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
end

puts Benchmark.measure {  arr.uniq.each { |v| names.insert(name_btree: v, name_gin: v) } }

searches = %w(nic foc ran de al mec)

Benchmark.bm do |x|
  x.report('btree') { searches.each { |s| names.where(Sequel.like(:name_btree, "%#{s}%")).count } }
  x.report('gin') { searches.each { |s| names.where(Sequel.like(:name_gin, "%#{s}%")).count } }
end
