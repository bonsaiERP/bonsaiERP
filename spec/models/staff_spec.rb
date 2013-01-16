# encoding: utf-8
require 'spec_helper'

describe Staff do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:position) }

  it "creates a new instance with staff true" do
    s = Staff.new
    s.should be_staff
  end
end

