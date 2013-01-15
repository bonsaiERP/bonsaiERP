# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Cash < Account

  # Relationships
  has_one :money_store, autosave: true, foreign_key: :account_id, dependent: :destroy

  # Delegations
  MONEY_METHODS = [:email, :address, :phone].freeze
  delegate *getters_setters_array(*MONEY_METHODS), to: :money_store

  # Validations
  validates :name, length: {:minimum => 3}

  # Initializes with an instance of MoneyStore
  def self.new_cash(attrs={})
    self.new do |c|
      c.build_money_store
      c.attributes = attrs
    end
  end

  def to_s
    name
  end

end

