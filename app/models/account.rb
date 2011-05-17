# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Account < ActiveRecord::Base
  acts_as_org

  # callbacks
  before_create :create_account_ledger

  # relationships
  belongs_to :currency
  has_many :account_ledgers, :order => "created_at DESC", :dependent => :destroy
  has_many :payments

  attr_accessor :amount
  attr_protected :total_amount

  delegate :name, :symbol, :code, :plural, :to => :currency, :prefix => true


  #validations
  validates_numericality_of :amount, :greater_than_or_equal_to => 0, :if => :new_record?
  validates_presence_of :currency_id
  validate :valid_currency_not_changed, :unless => :new_record?

  # scopes

  def self.json
    h = Hash.new {|h, v| h[v.id] = {:currency_id => v.currency_id , :type => v.type}  }
    Account.org.each {|ac| h[ac] }
    h
  end

  # If update occurs it should not allow
  def valid_currency_not_changed
    self.errors.add(:base, "No puede modificar la moneda") if changes[:currency_id]
  end

  def pendent_account_ledgers
    account_ledgers.pendent
  end

  # Prensents the total plus the account_ledgers not conciliated
  def total_pendent
    pendent_account_ledgers.sum(:amount) + total_amount
  end


  def total_amount
    read_attribute(:total_amount) || write_attribute(:total_amount, 0.0)
  end

  private
  # Creates the first income for the bank
  def create_account_ledger
    val = amount
    val = val.to_f
    ac = bank? ? "banco" : "caja"

    if val > 0
      bl = self.account_ledgers.build(:amount => amount, :date => Date.today, 
                                      :currency_id => currency_id,
                                      :income => true,
                                      :reference => 'Inicio',
                                      :contact_id => UserSession.user_id,
                                      :description => "Primer ingreso por creación de cuenta #{ac}")
    end
  end
end
