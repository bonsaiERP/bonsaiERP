# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base

  include Models::Organisation::NewOrganisation

  # callbacks
  before_create :set_amount
  #before_create :create_account_currency

  serialize :amount_currency

  attr_readonly  :initial_amount, :original_type
  attr_protected :amount, :amount_currency

  # relationships
  belongs_to :account_type
  belongs_to :currency
  belongs_to :accountable, :polymorphic => true

  has_many :account_ledgers
  has_many :account_ledger_details
  #has_many :account_currencies, :autosave => true
  # Transaction
  has_many :incomes,  :class_name => "Transaction", :conditions => "transactions.type = 'Income'"
  has_many :buys,     :class_name => "Transaction", :conditions => "transactions.type = 'Buy'"
  has_many :expenses, :class_name => "Transaction", :conditions => "transactions.type = 'Expense'"

  # validations
  validates_presence_of :currency_id, :name
  validates_numericality_of :amount

  # delegations
  delegate :symbol, :name, :to => :currency, :prefix => true

  # scopes
  scope :money, where(:accountable_type => "MoneyStore")
  scope :contact, where(:accountable_type => "Contact")

  # returns the class for a currency
  def cur(cur_id = nil)
    cur_id ||= currency_id
    ret = account_currencies.find_by_currency_id(cur_id)
    ret ||= AccountCurrency.new(:amount => 0, :currency_id => id)
    ret
  end

  # Returns the amount for one currency
  def amount_currency(cur_id = nil)
    cur_id ||= currency_id
    cur(cur_id).amount
  end

  def to_s
    name
  end

  def amount_to_conciliate()
    amount + account_ledger_details.sum(:amount)
  end

  # Returns all the related aacount_ledgers
  def get_ledgers
    t = "account_ledgers"
    AccountLedger.where("#{t}.account_id=:ac_id OR #{t}.to_id=:ac_id",:ac_id => id).order("created_at DESC")
  end

  # Creates a Hash with the id as the base
  def self.to_hash(*args)
    args = [:name, :currency_id] if args.empty?
    l = lambda {|v| args.map {|val| [val, v.send(val)] } }
    Hash[ Account.org.money.map {|v| [v.id, Hash[l.call(v)] ]  } ]
  end

  def self_with_currencies_hash(*args)
    {:name => name, :id => id, :currencies => currencies_to_hash }
  end

  # Creates a hash for with the amount for each curency available
  # {currency_id => amount}
  def currencies_to_hash
    Hash[ account_currencies.map {|ac| [ac.currency_id, ac.amount] } ]
  end

  def select_cur(cur_id)
    account_currencies.select {|ac| ac.currency_id == cur_id }.first
  end

  private
    def set_amount
      self.amount ||= 0.0
      self.initial_amount ||= self.amount
    end

    def create_account_currency
      account_currencies.build(
        :currency_id => currency_id, :amount => amount
      )
    end
end
