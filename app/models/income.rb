# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < IncomeExpenseModel

  ########################################
  # Callbacks
  before_save :set_client_and_incomes_status
  before_save :set_contact_incomes_status_null, if: :nulling_valid?

  ########################################
  # Relationships
  has_many :income_details, foreign_key: :account_id, dependent: :destroy, order: 'id asc'
  accepts_nested_attributes_for :income_details, allow_destroy: true,
    reject_if: proc {|det| det.fetch(:item_id).blank? }

  has_many :payments, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: 'payin'}
  has_many :payments_devolutions, class_name: 'AccountLedger', foreign_key: :account_id, conditions: {operation: ['payin', 'devin']}


  def self.new_income(attrs={})
    self.new do |i|
      i.build_transaction
      i.attributes = attrs
      i.state ||= 'draft'
      yield i if block_given?
    end
  end

  ########################################
  # Aliases, alias and alias_method not working
  [[:ref_number, :name], [:balance, :amount]].each do |meth|
    define_method meth.first do
      self.send(meth.last)
    end

    define_method :"#{meth.first}=" do |val|
      self.send(:"#{meth.last}=", val)
    end
  end

  def to_s
    ref_number
  end

  def self.get_ref_number
    ref = Income.order("name DESC").limit(1).pluck(:name).first
    year= Date.today.year.to_s[2..4]

    if ref.present?
      _, y, num = ref.split('-')
      if y == year
        "I-#{y}-#{num.next}"
      else
        "I-#{year}-0001"
      end
    else
      "I-#{year}-0001"
    end
  end

  def subtotal
    self.income_details.inject(0) {|sum, det| sum += det.total }
  end

private
  def set_client_and_incomes_status
    if contact.present?
      contact.client = true unless contact.client?

      set_contact_incomes_status if amount_changed? && !is_draft?

      contact.save if contact.changed?
    end
  end

  def set_contact_incomes_status
    contact.incomes_status = ContactBalanceStatus.new(pendent_contact_incomes).object_balance(self)
  end

  def set_contact_incomes_status_null
    contact.incomes_status = ContactBalanceStatus.new(pendent_contact_incomes).create_balances
  end

  def pendent_contact_incomes
    _id = id
    Income.pendent.contact(contact_id).where { id.not_eq _id }
    .select('sum(amount * exchange_rate) AS tot, sum(amount) AS tot_cur, currency')
    .group(:currency)
  end
end
