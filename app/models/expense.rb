# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Movement

  ########################################
  # Callbacks
  before_save :set_supplier_and_expenses_status
  before_save :set_contact_expenses_status_null, if: :nulling_valid?

  ########################################
  # Relationships
  has_many :expense_details, foreign_key: :account_id, dependent: :destroy, order: 'id asc'
  alias :items :expense_details

  accepts_nested_attributes_for :expense_details, allow_destroy: true,
    reject_if: proc {|det| det.fetch(:item_id).blank? }

  has_many :payments, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: 'payout'}
  has_many :interests, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: 'intout'}

  ########################################
  # Scopes
  scope :discount, -> { joins(:transaction).where(transaction: {discounted: true}) }
  scope :approved, -> { where(state: 'approved') }
  scope :active,   -> { where(state: ['approved', 'paid']) }
  scope :paid, -> { where(state: 'paid') }
  scope :contact, -> (cid) { where(contact_id: cid) }
  scope :pendent, -> { active.where{ amount.not_eq 0 } }
  scope :like, -> (s) {
    s = "%#{s}%"
    where{(name.like s) | (description.like s)}
  }
  scope :date_range, -> (range) { where(date: range) }

  def self.new_expense(attrs={})
    self.new do |e|
      e.build_transaction
      e.attributes = attrs
      e.state ||= 'draft'
      yield e if block_given?
    end
  end

  def self.get_ref_number
    ref = Expense.order("name DESC").limit(1).pluck(:name).first
    year= Date.today.year.to_s[2..4]

    if ref.present?
      _, y, num = ref.split('-')
      if y == year
        "E-#{y}-#{num.next}"
      else
        "E-#{year}-0001"
      end
    else
      "E-#{year}-0001"
    end
  end

  def subtotal
    self.expense_details.inject(0) {|sum, det| sum += det.total }
  end

private
  def set_supplier_and_expenses_status
    if contact.present?
      contact.supplier = true unless contact.supplier?

      set_contact_expenses_status if amount_changed? && !is_draft?

      contact.save if contact.changed?
    end
  end

  def set_contact_expenses_status
    contact.expenses_status = ContactBalanceStatus.new(pendent_contact_expenses).object_balance(self)
  end

  def set_contact_expenses_status_null
    contact.expenses_status = ContactBalanceStatus.new(pendent_contact_expenses).create_balances
  end

  def pendent_contact_expenses
    _id = id
    Expense.pendent.contact(contact_id).where { id.not_eq _id }
    .select('sum(amount * exchange_rate) AS tot, sum(amount) AS tot_cur, currency')
    .group(:currency)
  end
end
