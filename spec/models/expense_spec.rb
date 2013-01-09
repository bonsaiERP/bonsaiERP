require 'spec_helper'

describe Expense do
  let(:organisation) { build :organisation, id: 1 }
  let(:contact) { build :contact, id: 10 }

  before(:each) do
    OrganisationSession.set organisation
    Contact.any_instance.stub(save: true)
  end

  let(:valid_attributes) {
    {"active"=>nil, "bill_number"=>"56498797", "contact" => contact,
      "exchange_rate"=>1, "currency" => 'BOB', "date"=>'2011-01-24', 
      "description"=>"Esto es una prueba", "discount"=>3, 
      "ref_number"=>"987654"
    }
  }

  it 'check callback' do
    contact.should_receive(:update_attribute).with(:supplier, true)
    e = Expense.new(valid_attributes)

    e.save.should be_true
  end

  it "does not update contact to supplier" do
    contact.supplier = true
    contact.should_not_receive(:update_attribute).with(:supplier, true)
    e = Expense.new(valid_attributes)

    e.save.should be_true
  end
end
