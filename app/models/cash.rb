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
  validates :name, uniqueness: true, length: {:minimum => 3}

  def initialize(attrs={})
    h = {}
    MONEY_METHODS.each {|k| h[k] = attrs.delete(k) }
    super
    build_money_store h

    self
  end

  def to_s
    "#{name} #{currency}"
  end

end

