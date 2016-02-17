# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that creates incomes "Sales"
class Income < Movement

  include Models::History
  has_history_details Movements::History, :income_details

  self.code_name = 'I'

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
  has_many :income_details, -> { order('id asc') }, foreign_key: :account_id, dependent: :destroy
  alias_method :details, :income_details
  accepts_nested_attributes_for :income_details, allow_destroy: true,
    reject_if: proc { |det| det.fetch(:item_id).blank? }

  has_many :payments, -> { where(operation: 'payin') }, class_name: 'AccountLedger', foreign_key: :account_id
  has_many :devolutions, -> { where(operation: 'devout') }, class_name: 'AccountLedger', foreign_key: :account_id

  ########################################
  # Scopes
  scope :approved, -> { where(state: 'approved') }
  scope :active,   -> { where(state: ['approved', 'paid']) }
  scope :paid, -> { where(state: 'paid') }
  scope :contact, -> (cid) { where(contact_id: cid) }
  scope :pendent, -> { active.where.not(amount: 0) }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where("accounts.due_date < ?", Time.zone.now.to_date) }
  scope :nulled, -> { where(state: 'nulled') }
  scope :inventory, -> { active.where("extras->'delivered' = ?", 'false') }
  scope :like, -> (search) {
    search = "%#{search}%"
    t = Income.arel_table
    where(t[:name].matches(search).or(t[:description].matches(search) ) )
  }
  scope :date_range, -> (range) { where(date: range) }

  def subtotal
    self.income_details.inject(0) {|sum, det| sum += det.total }
  end

  def as_json(options = {})
    super(options).merge(income_details: income_details.map(&:attributes))
  end
end
