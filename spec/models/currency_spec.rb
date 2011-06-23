# encoding: utf-8
require 'spec_helper'

describe Currency do
  it 'should present a list' do
    currencies = YAML.load_file(File.join(Rails.root, "db/defaults/currencies.yml") )

    cont = 0
    arr = currencies.map do |val|
      cont += 1
      Currency.new(val) {|v| v.id = cont }
    end
    Currency.stubs(:all => arr)

    Currency.to_hash(:symbol, :name).should == {1 => {symbol: "Bs.", name: "boliviano"}, 2 => {symbol: "$", name: "dolar"}, 3 => {symbol: "€", name: "euro"}}
  end
end

