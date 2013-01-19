# encoding: utf-8
require 'spec_helper'

describe Currency do
  subject { Currency.new }

  it{ subject.list.should eq(CURRENCIES) }

  it "returns options list" do
    key = CURRENCIES.keys.first
    cur = CURRENCIES[key]
    subject.options.first.should eq(["#{key} #{cur.fetch(:name)}", key])
  end

  it "returns filtered currencies" do
    subject.options_filtered('BOB', 'USD').should eq([
      ["BOB #{CURRENCIES['BOB'].fetch(:name)}", 'BOB'],
      ["USD #{CURRENCIES['USD'].fetch(:name)}", 'USD']
    ])
  end

  it "returns the default" do
    subject.options_filtered.should eq([
      ["BOB #{CURRENCIES['BOB'].fetch(:name)}", 'BOB'],
      ["USD #{CURRENCIES['USD'].fetch(:name)}", 'USD'],
      ["EUR #{CURRENCIES['EUR'].fetch(:name)}", 'EUR']
    ])
  end
end

