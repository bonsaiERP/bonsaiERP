require 'spec_helper'
=begin
describe Loans::Form do
  let(:attributes) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232'
    }
  end

  context 'Loans::Receive' do
    it "$new_receive" do
      lf = Loans::Form.new_receive(attributes)

      # loan
      lf.loan.should be_is_a(Loans::Receive)
      lf.loan.amount.should == attributes.fetch(:total)
      lf.loan.date.should eq(attributes.fetch(:date))
      lf.loan.due_date.should eq(attributes.fetch(:due_date))
      # ledger
      lf.ledger.amount.should == 100
      expect(lf.ledger.operation).to eq('lrcre')
    end

    before(:each) {
      UserSession.user = build :user, id: 1
    }

    let(:cash) { create :cash, currency: 'BOB', amount: 0 }

    it "#create" do
      lf = Loans::Form.new_receive(attributes.merge(account_to_id: cash.id))

      lf.create.should be_true
      lf.loan.should be_persisted

      lf.ledger.should be_persisted

      c = Account.find(cash.id)
      c.amount.should == 100
    end
  end

  context 'Loans::Give' do
    it "$new_give" do
      lf = Loans::Form.new_give(attributes)

      # loan
      lf.loan.should be_is_a(Loans::Give)
      lf.loan.amount.should == attributes.fetch(:total)
      lf.loan.date.should eq(attributes.fetch(:date))
      lf.loan.due_date.should eq(attributes.fetch(:due_date))
      # ledger
      lf.ledger.amount.should == -100
      expect(lf.ledger.operation).to eq('lgcre')
    end
  end
end
=end
