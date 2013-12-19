require 'spec_helper'

describe Loans::Form do
  let(:attributes) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1, account_to_id: 1, exchange_rate: 1
    }
  end

  it { should validate_presence_of(:account_to_id) }
  it { should validate_presence_of(:reference) }
  it { should validate_numericality_of(:exchange_rate) }

  it "valid" do
    lf = Loans::Form.new(attributes)
    lf.should_not be_valid
    lf.errors[:account_to].should_not be_blank

    lf.stub(account_to: 'ye')
    lf.should be_valid
  end

end
