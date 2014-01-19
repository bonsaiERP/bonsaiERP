# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Expense < Movement

  include Models::History
  history_with_details :expense_details


  self.code_name = 'E'

  ########################################
  # Callbacks
  before_save :set_supplier_and_expenses_status
  before_save :set_contact_expenses_status_null, if: :nulling_valid?

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
  scope :discount, -> { joins(:transaction).where(transaction: { discounted: true }) }
  scope :approved, -> { where(state: 'approved') }
  scope :active,   -> { where(state: %w(approved paid)) }
  scope :paid, -> { where(state: 'paid') }
  scope :contact, -> (cid) { where(contact_id: cid) }
  scope :pendent, -> { active.where { amount.not_eq 0 } }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where{due_date < Date.today} }
  scope :nulled, -> { where(state: 'nulled') }
  #scope :inventory, -> { joins(:transaction).active.where('transactions.delivered' => false) }
  scope :like, -> (s) {
    s = "%#{s}%"
    where { (name.like s) | (description.like s) }
  }
  scope :date_range, -> (range) { where(date: range) }

  def subtotal
    expense_details.inject(0) { |sum, det| sum += det.total }
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
