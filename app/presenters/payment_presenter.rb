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

  def account(ac)
    case ac.original_type
    when "Bank"
      "#{ac} <small class='dashlet bg_green'>Banco</small>".html_safe
    when "Cash"
      "#{ac} <small class='dashlet bg_green'>Caja</small>".html_safe
    when "Client"
      "#{ac} <small class='dashlet bg_green'>Cliente</small>".html_safe
    when "Supplier"
      "#{ac} <small class='dashlet bg_green'>Proveedor</small>".html_safe
    when "Staff"
      "#{ac} <small class='dashlet bg_green'>Personal</small>".html_safe
    end
  end
end
