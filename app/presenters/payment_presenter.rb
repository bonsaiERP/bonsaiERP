class PaymentPresenter
  def initialize(transaction)
    @transaction = transaction
  end

  def accounts
    if @transaction.is_a? Income
      Account.org.contact_money(@transaction.contact_id)
    else
      Account.org.contact_money_buy(@transaction.contact_id)
    end
  end

  def to_hash
    Hash[accounts.values_of(:id, :name , :currency_id).map do |a, b, c|
      [a, {:name => b, :currency_id => c}]
    end]
  end
end
