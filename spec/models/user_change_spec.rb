require 'spec_helper'

describe UserChange do
  it {should have_valid(:user_id).when(1) }
  it {should have_valid(:name).when('name') }
  it {should_not have_valid(:name).when(' ') }
end
