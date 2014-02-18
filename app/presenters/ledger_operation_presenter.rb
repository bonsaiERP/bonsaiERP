class LedgerOperationPresenter < BasePresenter
  attr_reader :current_id, :klass

  delegate :operation_tag, :operation_text, to: :klass

  def initialize(ledger, current_id, v_context)
    super(ledger, v_context)
    @current_id = current_id
    set_operation_klass
  end

  def set_operation_klass
    if unrelated_operation?
      @klass = UnrelatedOperation.new(self)
    elsif is_positive?
      @klass = PositiveLedgerOperation.new(self)
    elsif is_negative?
      @klass = NegativeLedgerOperation.new(self)
    end
  end

  def unrelated_operation?
    ['trans', 'payin', 'devin', 'payout', 'devout',
     'lrcre', 'lrpay', 'lrint',
     'lgcre', 'lgpay', 'lgint'
    ].include?(operation)
  end

  def related_operation?
    ['servex', 'servin'].include?(operation)
  end

  def is_positive?
    current_id == account_id && account.is_a?(Income) || current_id == account_to_id && account_to.is_a?(Income)
  end

  def is_negative?
    current_id == account_id && account.is_a?(Expense) || current_id == account_to_id && account_to.is_a?(Expense)
  end
end

# No relation for current_account_id
class UnrelatedOperation < Struct.new(:presenter)
  delegate :operation, :text_green, :text_red, to: :presenter

  def operation_tag
    case operation
    when 'payin', 'devout', 'lrcre', 'lgpay', 'lgint'
      text_green(operation_text)
    when 'payout', 'devin', 'lgcre', 'lrpay', 'lrint'
      text_red(operation_text)
    when 'trans'
      'Transferencia'
    end
  end

  def operation_text
    case operation
      when 'trans' then 'Transferencia'
      when 'payin' then 'Cobro ingreso'
      when 'payout' then 'Pago egreso'
      when 'devin' then 'Devolución ingreso'
      when 'devout' then 'Devolución egreso'
      when 'lrcre' then 'Ingreso prestamo'
      when 'lrpay' then 'Pago perstamo'
      when 'lrint' then 'Pago intereses'
      when 'lgcre' then 'Egreso prestamo'
      when 'lgint' then 'Cobro intereses'
      when 'lgpay' then 'Cobro prestamo'
    end
  end
end

# For Account
class PositiveLedgerOperation < Struct.new(:presenter)
  delegate :operation, :text_green, :text_red, to: :presenter

  def operation_tag
    text_green operation_text
  end

  def operation_text
    'Cobro contra servicio'
  end
end

# For AccountTo
class NegativeLedgerOperation < Struct.new(:presenter)
  delegate :operation, :text_green, :text_red, to: :presenter

  def operation_tag
    text_red operation_text
  end

  def operation_text
    'Pago contra servicio'
  end
end
