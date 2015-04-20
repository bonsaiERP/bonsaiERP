require 'spec_helper'

describe Expenses::BatchPayment do
  before(:each) do
    UserSession.user = build :user, id: 10
  end

  let(:cash) { create :cash, amount: 0 }
  let(:contact) { create :contact }

  it "#make_payments" do
    e1 = build(:expense, state: 'approved', balance: 100, contact_id: contact.id)
    e2 = build(:expense, name: 'E-0002', state: 'approved', balance: 100, contact_id: contact.id)
    e1.stub(valid?: true)
    e2.stub(valid?: true)
    e1.save!
    e2.save!

    expect(e1.total).to eq(100)
    expect(e2.total).to eq(100)

    b_pay = Expenses::BatchPayment.new(ids: [e1.id, e2.id], account_to_id: cash.id)
    expect(b_pay.expenses.size).to eq(2)


    b_pay.make_payments

    expect(e1.reload.balance).to eq(0)
    expect(e2.reload.balance).to eq(0)

    led1 = AccountLedger.find_by(account_id: e1.id)
    expect(led1.reference).to eq("Pago egreso #{e1.name}")
    expect(led1.amount).to eq(-e1.total)

    led2 = AccountLedger.find_by(account_id: e2.id)
    expect(led2.reference).to eq("Pago egreso #{e2.name}")
    expect(led2.amount).to eq(-e2.total)

    expect(cash.reload.amount).to eq(-200)
  end

  it "#make_payments error" do
    e1 = build(:expense, state: 'approved', balance: -10, contact_id: contact.id)

    e1.stub(valid?: true)
    e1.save!

    b_pay = Expenses::BatchPayment.new(ids: [e1.id], account_to_id: cash.id)

    b_pay.make_payments

    expect(b_pay.errors.size).to eq(1)
    expect(b_pay.errors).to eq([I18n.t('errors.messages.expenses.batch_payment.problem', name: e1.name)])

    e1.balance = '100'
    e1.state = 'draft'
    e1.save!

    b_pay = Expenses::BatchPayment.new(ids: [e1.id], account_to_id: cash.id)
    b_pay.make_payments

    expect(b_pay.errors.size).to eq(1)
    expect(b_pay.errors).to eq([I18n.t('errors.messages.expenses.batch_payment.problem', name: e1.name)])
  end
end
