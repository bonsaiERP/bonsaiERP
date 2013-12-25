# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < Account

  # module
  extend SettersGetters

  # Store accessors
  EXTRA_COLUMNS = [:email, :address, :phone, :website].freeze
  store_accessor( *([:extras] + EXTRA_COLUMNS))


  # can't use Bank.stored_attributes methods[:extras]
  alias_method :old_attributes, :attributes
  def attributes
    old_attributes.merge(
      Hash[EXTRA_COLUMNS.map { |k| [k.to_s, send(k)] }]
    )
  end

  def pendent_ledgers
    AccountLedgers::Query.new.money(id).pendent
  end

  def ledgers
    AccountLedgers::Query.new.money(id)
  end

  def to_s
    name
  end

  def get_ledgers(attrs = {})
    ledgers = AccountLedgers::Query.new.money(id)
    ledgers = ledgers.pendent if attrs[:pendent].present?
    ledgers
  end

  private

    def set_defaults
      self.total_amount ||= 0.0
    end
end
