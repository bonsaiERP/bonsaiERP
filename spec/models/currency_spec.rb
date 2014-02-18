# encoding: utf-8
require 'spec_helper'

describe Currency do

  it "options" do
    Currency.options('BOB', 'PEN', 'ARS').should eq([
      ['BOB Boliviano', 'BOB'],['PEN Nuevo Sol Peruano', 'PEN'], ['ARS Peso Argentino', 'ARS']
    ])
  end

  it "!find" do
    Currency.find('USD').should eq(Currency.new(CURRENCIES['USD']))
  end
end

