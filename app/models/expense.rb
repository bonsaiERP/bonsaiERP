# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Movement

  include Models::History
  has_history_details Movements::History, :expense_details

  self.code_name = 'E'

  jsonb_accessor(:extras,
    {delivered: :boolean,
    discounted: :boolean,
    devolution: :boolean,
    gross_total: :decimal,
    inventory: :boolean,
    balance_inventory: :decimal,
    original_total: :decimal,
    bill_number: :string,
    null_reason: :string,
    operation_type: :string,
    nuller_datetime: :date_time,
    approver_datetime: :date_time})
  ########################################
  # Relationships
  has_many :expense_details, -> { order('id asc') },
           foreign_key: :account_id, dependent: :destroy
  alias_method :details, :expense_details

  accepts_nested_attributes_for :expense_details, allow_destroy: true,
                                reject_if: proc { |det| det.fetch(:item_id).blank? }

  has_many :payments, -> { where(operation: 'payout') },
           class_name: 'AccountLedger', foreign_key: :account_id
  has_many :devolutions, -> { where(operation: 'devin') },
           class_name: 'AccountLedger', foreign_key: :account_id

  ########################################
  # Scopes
  scope :approved, -> { where(state: 'approved') }
  scope :active,   -> { where(state: %w(approved paid)) }
  scope :paid, -> { where(state: 'paid') }
  scope :contact, -> (cid) { where(contact_id: cid) }
  scope :pendent, -> { active.where.not(amount: 0) }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where("accounts.due_date < ?", Time.zone.now.to_date) }
  scope :nulled, -> { where(state: 'nulled') }
  scope :inventory, -> { active.where("extras->'delivered' = ?", 'false') }
  scope :like, -> (s) {
    s = "%#{s}%"
    t = Expense.arel_table
    where(t[:name].matches(s).or(t[:description].matches(s) ) )
  }
  scope :date_range, -> (range) { where(date: range) }

  def subtotal
    expense_details.inject(0) { |sum, det| sum += det.total }
  end

  def as_json(options = {})
    super(options).merge(expense_details: expense_details.map(&:attributes))
  end
end
