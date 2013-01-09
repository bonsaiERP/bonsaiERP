#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationSession do
  let(:organisation) { build :organisation, id: 100 }
  before(:each) do
    OrganisationSession.set organisation
  end
  subject{ OrganisationSession }

  it 'should allow to be set ussing a Hash' do
    subject.organisation_id.should eq(100)

    [:name, :tenant, :currency].each do |meth|
      subject.send(meth).should eq(organisation.send(meth))
    end
  end
end
