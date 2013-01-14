# encoding: utf-8
require 'spec_helper'

describe OrgCountry do
  it { should have_valid(:name).when('Bolivia', 'Perú', 'Chile') }
  it { should_not have_valid(:name).when('', nil) }
  it { should have_valid(:code).when('BO', 'US') }
  it { should_not have_valid(:code).when(nil, '') }

end
