require 'spec_helper'

describe Loans::Receive do
  let(:attributes) {
    today = Date.today
    {
      name: 'P-0001', currency: 'BOB', date: today,
      due_date: today + 10.days, total: 100,
      account_to_id: 10
    }
  }

  it { should have_one(:ledger_in) }

  it "#initialize with code" do
    l = Loans::Receive.new {}
    y = Date.today.year.to_s[2..4]
    expect(l.name).to eq("PR-#{y}-0001")
  end

  context 'AccountLedger' do
    before(:each) do
      UserSession.user = build :user, id: 1
    end

    let(:account_to) { build :account, id: attributes.fetch(:account_to_id) }

    it "#create" do
      l = Loans::Receive.new(attributes)
      account_to.stub(save: true)

      ConciliateAccount.any_instance.should_receive(:account_to).and_return(account_to)

      l.create#.should be_true

      puts l.send(:ledger).errors.messages
      expect(l.ledger).to be_is_a(AccountLedger)
      l.ledger.amount.should == 100

      l.ledger.should be_is_lrcre
    end
  end

end
