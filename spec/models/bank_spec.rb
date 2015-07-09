require 'spec_helper'

describe Bank do
  let(:valid_attributes) {
    { currency: 'BOB', name: 'Banco Uno 12365498', address: 'Uno', amount: 100, phone: '55-6678', website: 'mind.com' }
  }


  it "returns to_s" do
    b = Bank.new name: 'Banco Central 121-121289'
    b.to_s.should eq("Banco Central 121-121289")
  end

  it 'should create an instance' do
    UserSession.user = build :user, id: 1
    b = Bank.new(valid_attributes)

    b.save.should eq(true)

    valid_attributes.each do |k, v|
      b.send(k).should eq(v)
    end
  end


  it 'should update attributes' do
    UserSession.user = build :user, id: 1
    b = Bank.new(valid_attributes)
    b.save.should eq(true)
    b.should be_persisted

    h = {:website => "www.bnb.com.bo", :address => "Very near", :phone => "2798888"}
    b.update_attributes(h).should eq(true)

    b.reload

    h.each do |k, v|
      b.send(k).should eq(v)
    end
  end

  it "#attributes" do
    attrs = { email: 'test@mail.com', address: 'Por ahi', phone: '555 555', website: 'mysite..com' }
    b = Bank.new(attrs)

    attrs.each do |k, v|
      b.attributes[k.to_s].should eq(v)
    end
  end

end
