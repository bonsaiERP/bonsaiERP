# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base

  include Models::Organisation::NewOrganisation
  include ActionView::Helpers::NumberHelper 

  # callbacks
  before_create :set_amount
  #before_create :create_account_currency

  #serialize :amount_currency

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
  validates_presence_of :currency, :name
  validates_numericality_of :amount
  validates_associated :currency
  #validates :currency_id, :organisation_relation => true

  # delegations
  delegate :symbol, :name, :to => :currency, :prefix => true, :allow_nil => true

  # scopes
  scope :money, where(:accountable_type => "MoneyStore")
  scope :contact, where(:accountable_type => "Contact")
  scope :client, where(:original_type => "Client")
  scope :supplier, where(:original_type => "Supplier")
  scope :staff, where(:original_type => "Staff")
  scope :contact_money, lambda {|*account_ids|
    s = self.scoped
    s.where( s.table[:accountable_type].eq('Contact')
      .and(s.table[:accountable_id].in(account_ids))
      .and(s.table[:amount].lt(0))
      .or(s.table[:accountable_type].eq('MoneyStore'))
    ).order("accountable_type")
  }
  scope :contact_money_buy, lambda{|account_ids|
    s = self.scoped
    s.where( 
      s.table[:accountable_type].eq('Contact')
      .and(s.table[:accountable_id].in(account_ids))
      .and(s.table[:amount].gt(0) )
      .or(s.table[:original_type].eq('Staff').and(s.table[:amount].gt(0)) )
      .or(s.table[:accountable_type].eq('MoneyStore'))
    ).order("accountable_type")
  }
  scope :to_pay, contact.where("amount < 0")
  scope :to_recieve, contact.where("amount > 0")

  def to_s
    if accountable_type === "Contact"
      "#{name} (#{currency_symbol} #{number_with_delimiter(amount.abs)})"
    else
      "#{name} (#{currency_symbol} #{number_with_delimiter(amount)})"
    end
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

  # Creates a hash for with the amount for each curency available
  # {currency_id => amount}
  def currencies_to_hash
    Hash[ account_currencies.map {|ac| [ac.currency_id, ac.amount] } ]
  end

  def select_cur(cur_id)
    account_currencies.select {|ac| ac.currency_id == cur_id }.first
  end

  # Returns all account_ledgers for an account_id and to_id
  def self.get_ledgers(includes = [:account, :to])
    AccountLedger.includes(*includes)
    .where("account_ledgers.account_id = :id OR account_ledgers.to_id = :id", :id => id)
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
