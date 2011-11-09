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
    Currency.stub!(:all => arr)

    Currency.to_hash(:symbol, :name).should == {1 => {:symbol => "Bs.", :name => "Boliviano"}, 2 => {:symbol => "$us", :name => "Dolar"}, 3 => {:symbol => "€", :name => "Euro"}}
  end

  it 'should create base data' do
    Currency.count.should == 0
    Currency.create_base_data
    Currency.count.should > 0
    Currency.first.id.should == 1
    Currency.first.code.should == "BOB"
  end
end

