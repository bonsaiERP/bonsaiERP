# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Movement

  include Models::History
  has_movement_history :expense_details

  self.code_name = 'E'

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
  scope :pendent, -> { active.where { amount.not_eq 0 } }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where{due_date < Date.today} }
  scope :nulled, -> { where(state: 'nulled') }
  #scope :inventory, -> { joins(:transaction).active.where('transactions.delivered' => false) }
  scope :like, -> (search) {
    search = "%#{search}%"
    where { (name.like search) | (description.like search) }
  }
  scope :date_range, -> (range) { where(date: range) }

  def subtotal
    expense_details.inject(0) { |sum, det| sum += det.total }
  end

end
