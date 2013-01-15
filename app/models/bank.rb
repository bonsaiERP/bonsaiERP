# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < Account

  # Relationships
  has_one :money_store, autosave: true, foreign_key: :account_id

  # Delegations
  MONEY_METHODS = [:number, :email, :address, :phone, :website].freeze
  delegate *getters_setters_array(*MONEY_METHODS), to: :money_store

  # validations
  validates_presence_of :name, :currency, :number
  validates :number, length: {within: 3..30}

  def initialize(attrs={})
    h = attrs.slice(*MONEY_METHODS)
    MONEY_METHODS.each {|k| attrs.delete(k) }
    super
    build_money_store h
    self
  end

  def to_s
    "#{name} #{number}"
  end

  private
  def set_defaults
    self.total_amount ||= 0.0
  end
end
