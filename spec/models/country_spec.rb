# encoding: utf-8
require 'spec_helper'

describe Country do
  it "returns the complete name" do
    c = Country.find('BO')
    c.to_s.should eq('Bolivia BO')

    c = Country.find('AR')
    c.to_s.should eq('Argentina AR')
  end

  it "returns the options" do
    countries = COUNTRIES.keys.slice(0,4)

    options = Country.options

    options.should be_is_a(Array)

    (0..3).each do |v|
      c = Country.find(countries[v])
      options[v].should eq([c.to_s, c.code])
    end
  end
end
