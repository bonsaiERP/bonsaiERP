require 'spec_helper'

describe Tag do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:bgcolor) }

  it { should have_valid(:name).when('a', 'uno', 'buena-cosa') }
  it { should_not have_valid(:name).when('', 'uno,-a', 'buena cosa') }

  it { should have_valid(:bgcolor).when('#fffaba', '#FFFABA', '#000000') }
  it { should_not have_valid(:bgcolor).when('#fffaba3', '000000','#0d0d0g') }
end
