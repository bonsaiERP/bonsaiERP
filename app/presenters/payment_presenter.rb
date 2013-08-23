# encoding: utf-8
class PaymentPresenter
  def initialize(transaction)
    @transaction = transaction
  end

  def accounts
    if @transaction.is_a? Income
      Account.contact_money(@transaction.contact_id)
    else
      Account.contact_money_buy(@transaction.contact_id)
    end
  end

  def devolution_accounts
    [Account.contact_account(@transaction.contact_id, @transaction.currency_id)] + Account.money.all
  end

  def to_hash
    Hash[accounts.pluck(:id, :name , :currency_id).map do |a, b, c|
      [a, {:name => b, :currency_id => c}]
    end]
  end

end
