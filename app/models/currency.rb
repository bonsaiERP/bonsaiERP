# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Currency < ActiveRecord::Base

  self.table_name = "common.currencies"

  has_many :organisations

  validates_presence_of :name, :symbol

  def to_s
    %Q(#{symbol} #{name})
  end

  def plural
    %Q(#{name.pluralize} #{symbol})
  end

  def self.to_hash(*args)
    args = [:id, :name, :symbol, :code] if args.empty?
    l = lambda {|v| args.map {|val| [val, v.send(val)] } }

    Hash[ Currency.all.map {|v| [v.id, Hash[l.call(v)] ]  } ]
  end

  def self.create_base_data
    path = File.join(Rails.root, "db/defaults", "currencies.yml")
    currencies = YAML.load_file(path)
    currencies.each do |cur|
      Currency.create!(cur) {|cu| cu.id = cur["id"]}
    end
  end
end
