require 'spec_helper'

describe OrgCountry do
  it 'should create many countries' do
    OrgCountry.count.should == 0
    OrgCountry.create_base_data
    OrgCountry.count.should > 0
    OrgCountry.first.id.should == 1
    OrgCountry.first.name.should == "Bolivia"
  end
end
