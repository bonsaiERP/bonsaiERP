require 'spec_helper'

describe Incomes::BatchPayment do
  before(:each) do
    UserSession.user = build :user, id: 10
  end

  let(:cash) { create :cash, amount: 0 }
  let(:contact) { create :contact }

  it "#make_payments" do
    i1 = build(:income, state: 'approved', balance: 100, contact_id: contact.id)
    i2 = build(:income, name: 'I-0002', state: 'approved', balance: 100, contact_id: contact.id)
    i1.stub(valid?: true)
    i2.stub(valid?: true)
    i1.save!
    i2.save!

    expect(i1.total).to eq(100)
    expect(i2.total).to eq(100)

    b_pay = Incomes::BatchPayment.new(ids: [i1.id, i2.id], account_to_id: cash.id)
    expect(b_pay.incomes.size).to eq(2)


    b_pay.make_payments

    expect(i1.reload.balance).to eq(0)
    expect(i2.reload.balance).to eq(0)

    led1 = AccountLedger.find_by(account_id: i1.id)
    expect(led1.reference).to eq("Cobro ingreso #{i1.name}")
    expect(led1.amount).to eq(i1.total)

    led2 = AccountLedger.find_by(account_id: i2.id)
    expect(led2.reference).to eq("Cobro ingreso #{i2.name}")
    expect(led2.amount).to eq(i2.total)
  end

  it "#make_payments error" do
    i1 = build(:income, state: 'approved', balance: -10, contact_id: contact.id)

    i1.stub(valid?: true)
    i1.save!

    b_pay = Incomes::BatchPayment.new(ids: [i1.id], account_to_id: cash.id)

    b_pay.make_payments

    expect(b_pay.errors.size).to eq(1)
    expect(b_pay.errors).to eq([I18n.t('errors.messages.incomes.batch_payment.problem', name: i1.name)])

    i1.balance = '100'
    i1.state = 'draft'
    i1.save!

    b_pay = Incomes::BatchPayment.new(ids: [i1.id], account_to_id: cash.id)
    b_pay.make_payments

    expect(b_pay.errors.size).to eq(1)
    expect(b_pay.errors).to eq([I18n.t('errors.messages.incomes.batch_payment.problem', name: i1.name)])
  end
end
