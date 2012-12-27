# encoding: utf-8
require 'spec_helper'

describe PaymentIncome do
  let(:valid_attributes) {
    {
      transaction_id: 10, account_id: 2, exchange_rate: 1,
      amount: 50, interest: 0, reference: 'El primer pago'
    }
  }

  let(:transaction_id) { valid_attributes[:transaction_id] }
  let(:account_id) { valid_attributes[:account_id] }

end
