require 'spec_helper'
=begin
describe Loans::Give do
  it "#initialize with code" do
    l = Loans::Give.new {}
    y = Date.today.year.to_s[2..4]
    expect(l.name).to eq("PG-#{y}-0001")
  end
end
=end
