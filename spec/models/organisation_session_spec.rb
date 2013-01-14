#require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganisationSession do
  let(:organisation) { build :organisation, id: 100 }
  before(:each) do
    OrganisationSession.organisation = organisation
  end
  subject{ OrganisationSession }

  it "does not allow other objects" do
    expect { OrganisationSession.organisation = Object.new }.to raise_error
  end

  it 'should allow to be set ussing a Hash' do
    subject.id.should eq(100)

    [:name, :tenant, :currency].each do |meth|
      subject.send(meth).should eq(organisation.send(meth))
    end
  end
end
