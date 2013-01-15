require 'spec_helper'

describe Bank do
  let(:valid_attributes) {
    {currency: 'BOB', name: 'Banco 1', number: '12365498', address: 'Uno', amount: 100}
  }

  describe "Validations" do
    subject { Bank.new }

    it { should have_valid(:number).when('121', '121hjs121') }
    it { should_not have_valid(:number).when('', '12')}
  end

  it 'should create an instance' do
    b = Bank.new(valid_attributes)

    b.save.should be_true

    valid_attributes.each do |k, v|
      b.send(k).should eq(v)
    end
  end


  it 'should update attributes' do
    b = Bank.new(valid_attributes)
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
