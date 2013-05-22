# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::Form < BaseForm
  attribute :id, Integer
  attribute :ref_number, String
  attribute :date, Date
  attribute :contact_id, Integer
  attribute :currency, String
  attribute :total, Decimal
  attribute :exchange_rate, Decimal
  attribute :project_id, Integer
  attribute :due_date, Date
  attribute :description, String
  attribute :direct_payment, Boolean
  attribute :account_to_id, Integer
  attribute :reference, String

  ATTRIBUTES = [:date, :contact_id, :total, :exchange_rate, :project_id, :due_date, :description, :direct_payment, :account_to_id, :reference].freeze

  attr_reader :movement, :ledger, :history

  validates_presence_of :movement
  validates_numericality_of :total
  validate :unique_item_ids

  # Finds the income and sets data with the income found
  def set_service_attributes(mov)
    [:ref_number, :date, :due_date, :currency, :exchange_rate, 
     :project_id, :description, :total].each do |attr|
      self.send(:"#{attr}=", mov.send(attr))
    end

    @movement    = mov
  end

  def create
    set_direct_payment if direct_payment?

    res = valid_service?
    @movement.balance = 0 if direct_payment?

    res = save_service(res) do
            res = @movement.save
            res = res && save_ledger if direct_payment?

            res
          end

    res
  end

  def update(attrs = {})
    set_update_data(attrs)

    set_direct_payment if direct_payment?

    res = valid_service?
    @movement.balance = 0 if direct_payment?

    res = save_service(res) do
            res = @history.save
            res = res && @movement.save
            res = res && save_ledger if direct_payment?

            res
          end

    res
  end

private
  def valid_service?
    res = valid?
    res = @movement.valid? && res
    res = valid_ledger? && res if direct_payment?

    res
  end

  def set_direct_payment
    build_ledger
    @movement.state = 'paid'
  end

  def save_ledger
    @ledger.account_id = @movement.id

    @ledger.save_ledger
  end

  def save_service(res, &block)
    res = commit_or_rollback{ block.call } if res

    unless res
      @movement.errors.messages.select{|k| @movement.errors.delete(k) if k =~ /\w+_details/ }
      set_errors(*[@movement, @ledger].compact)
    end

    res
  end

  def set_update_data(attrs = {})
    @history = TransactionHistory.new
    @history.set_history(@movement)
    self.attributes = attrs.slice(*attributes_for_update)
    MovementService.new(@movement).set_update(attrs)
  end

  def valid_ledger?
    @ledger.valid?
    @ledger.errors.keys.sort === [:account, :account_id] || @ledger.errors.keys.empty?
  end

  # validates unique items
  def unique_item_ids
    UniqueItem.new(self).valid?
  end

  def direct_payment?
    direct_payment === true
  end

  def attributes_for_update
    ATTRIBUTES.reject {|v| v === :contact_id }
  end
end
