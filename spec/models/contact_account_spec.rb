# encoding: utf-8
require 'spec_helper'

describe ContactAccount do
  it "sets a new instance with defaults" do
    c = ContactAccount.new
    c.type.should eq('ContactAccount')
  end
end
