require 'spec_helper'

describe Loans::ReceivePresenter do
  let(:view_context) { ActionView::Base.new }
  let(:loan) { build :loan_give, id: 10 }
  let (:loan_p) { Loans::ReceivePresenter.new(loan, view_context) }

  it '#new_ledger_in_path' do
    allow(view_context).to receive(:new_receive_loan_ledger_in_path).with(10).and_return("/loan_ledger_ins/10/new_receive")

    expect(loan_p.new_ledger_in_path).to eq("/loan_ledger_ins/10/new_receive")
  end

  it '#ledger_in_path' do
    allow(view_context).to receive(:receive_loan_ledger_in_path).with(10).and_return("/loan_ledger_ins/10/receive")

    expect(loan_p.ledger_in_path).to eq("/loan_ledger_ins/10/receive")
  end
end
