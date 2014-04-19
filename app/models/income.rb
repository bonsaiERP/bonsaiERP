# author: Boris Barroso
# email: boriscyber@gmail.com
# Class that creates incomes "Sales"
class Income < Movement

  include Models::History
  has_history_details Movements::History, :income_details

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
  scope :pendent, -> { active.where.not(amount: 0) }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where{due_date < Date.today} }
  scope :nulled, -> { where(state: 'nulled') }
  scope :inventory, -> { active.where("extras->'delivered' = ?", 'false') }
  scope :like, -> (search) {
    search = "%#{search}%"
    t = Income.arel_table
    where(t[:name].matches(search).or(t[:description].matches(search) ) )
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
