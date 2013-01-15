# encoding: utf-8
require 'spec_helper'

describe MoneyStore do
  it { should belong_to(:account) }
end
