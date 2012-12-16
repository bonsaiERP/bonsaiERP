require 'spec_helper'

describe Transaction do
  let(:user) {build :user, id: 10}
  let(:contact) { build :contact, id: 2 }
  let(:currency) { build :currency, id: 3 }

  before(:each) do
    UserSession.current_user = user
    User.stub!(find: user)
    Contact.stub!(find: contact)
    Currency.stub!(find: currency)
  end

  let(:valid_attributes) {
    {
      date: Date.today, currency_id: currency.id, contact_id: contact.id,
    }
  }


  context "User changes" do
    it "creates many user changes" do
      t = Transaction.new(valid_attributes)
      t.currency = currency
      t.contact = contact

      t.user_changes.build(name: 'creator') {|uc| uc.user = user}
      t.user_changes.build(name: 'approver') {|uc| uc.user = user}

      t.save.should be_true

      t.user_changes.should have(2).items

      ['creator', 'approver'].should be_include(t.user_changes[0].name)
      t.user_changes[0].should be_persisted
      ['creator', 'approver'].should be_include(t.user_changes[1].name)
      t.user_changes[1].should be_persisted
    end
  end
end
