require 'spec_helper'

describe Loans::Form do
  let(:attributes) do
    today = Date.today
    {
      date: today, due_date: today + 10.days, total: 100,
      reference: 'Receipt 00232', contact_id: 1
    }
  end

  #it { should validate_presence_of(:account) }
  it "valid" do
    lf = Loans::Form.new
    lf.should_not be_valid
    lf.errors[:account_to].should_not be_blank

    lf.stub(account_to: 'ye')
    lf.should be_valid
  end

end
