require 'spec_helper'

describe Bank do
  let(:valid_attributes) {
    {currency: 'BOB', name: 'Banco 1', number: '12365498', address: 'Uno', amount: 100}
  }

  describe "Validations, Relationships" do
    subject { Bank.new_bank }

    it { should have_one(:money_store) }
    it { should validate_presence_of(:number) }

    it { should have_valid(:number).when('121', '121hjs121') }
    it { should_not have_valid(:number).when('', '12')}
  end

  it "returns to_s" do
    b = Bank.new_bank name: 'Banco Central', number: '121-121289'
    b.to_s.should eq("Banco Central 121-121289")
  end

  it 'should create an instance' do
    b = Bank.new_bank(valid_attributes)

    b.save.should be_true

    valid_attributes.each do |k, v|
      b.send(k).should eq(v)
    end
  end


  it 'should update attributes' do
    b = Bank.new_bank(valid_attributes)
    b.save.should be_true
    b.should be_persisted   

    h = {:website => "www.bnb.com.bo", :address => "Very near", :phone => "2798888"}
    b.update_attributes(h).should be_true

    b.reload
    
    h.each do |k, v|
      b.send(k).should eq(v)
    end
  end

end
