require 'spec_helper'

describe Loans::Receive do
  it "#initialize" do
    l = Loans::Receive.new
    puts l.type
  end
end
