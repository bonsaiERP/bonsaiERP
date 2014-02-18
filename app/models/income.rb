# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Movement

  include Models::History
  has_movement_history :income_details

  self.code_name = 'I'

  ########################################
  # Relationships
  has_many :income_details, -> { order('id asc') }, foreign_key: :account_id, dependent: :destroy
  alias :details :income_details
  accepts_nested_attributes_for :income_details, allow_destroy: true,
    reject_if: proc {|det| det.fetch(:item_id).blank? }

  has_many :payments, -> { where(operation: 'payin') }, class_name: 'AccountLedger', foreign_key: :account_id
  has_many :devolutions, -> { where(operation: 'devout') }, class_name: 'AccountLedger', foreign_key: :account_id

  ########################################
  # Scopes
  #scope :discount, -> { joins(:transaction).where(transaction: {discounted: true}) }
  scope :approved, -> { where(state: 'approved') }
  scope :active,   -> { where(state: ['approved', 'paid']) }
  scope :paid, -> { where(state: 'paid') }
  scope :contact, -> (cid) { where(contact_id: cid) }
  scope :pendent, -> { active.where{ amount.not_eq 0 } }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where{due_date < Date.today} }
  scope :nulled, -> { where(state: 'nulled') }
  scope :inventory, -> { approved.where("(extras->'delivered')::boolean = ?", false) }
  scope :like, -> (s) {
    s = "%#{s}%"
    where{(name.like s) | (description.like s)}
  }
  scope :date_range, -> (range) { where(date: range) }

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

  def subtotal
    self.income_details.inject(0) {|sum, det| sum += det.total }
  end

end
