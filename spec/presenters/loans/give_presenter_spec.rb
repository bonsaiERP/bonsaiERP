require 'spec_helper'

describe Loans::GivePresenter do
  let(:view_context) { ActionView::Base.new }
  let(:loan) { build :loan_give, id: 10 }
  let (:loan_p) { Loans::GivePresenter.new(loan, view_context) }

  it '#new_ledger_in_path' do
    allow(view_context).to receive(:new_give_loan_ledger_in_path).with(10).and_return("/loan_ledger_ins/10/new_give")

    expect(loan_p.new_ledger_in_path).to eq("/loan_ledger_ins/10/new_give")
  end

  it '#ledger_in_path' do
    allow(view_context).to receive(:give_loan_ledger_in_path).with(10).and_return("/loan_ledger_ins/10/give")

    expect(loan_p.ledger_in_path).to eq("/loan_ledger_ins/10/give")
  end

end
