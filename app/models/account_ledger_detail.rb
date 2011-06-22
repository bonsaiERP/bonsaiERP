# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerDetail < ActiveRecord::Base
  acts_as_org

  STATES = %w(uncon con)

  STATES.each do |st|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{st}?
        state == "#{st}"
      end
    CODE
  end
  
  # callbacks
  before_validation :set_values, :if => :new_record?
  before_save :update_account_amount, :if => :con?

  belongs_to :account
  belongs_to :account_ledger
  belongs_to :related, :class_name => "AccountLedgerDetail"

  validates_presence_of :account_id, :state
  validates_numericality_of :amount

  # scopes
  scope :pendent, org.where(:state => "uncon")

  def self.pendent?
    self.pendent.count > 0
  end
  
  def amount_currency
    exchange_rate * amount
  end

  private

    def set_values
      self.exchange_rate ||= 1
      self.state ||= "con"
      self.currency_id ||= account.currency_id
    end

    # updates it's account
    def update_account_amount
      account.amount = account.amount + amount if currency_id == account.currency_id
      
      update_account_currency
      account.save
    end

    # 
    def update_account_currency
      acur = account.account_currencies.select {|ac| ac.currency_id == currency_id }
      if acur.any?
        acur = acur.first
        acur.amount = acur.amount.to_f + amount
      else
        acur = account.account_currencies.build(:currency_id => currency_id, :amount => amount)
      end
    end

end
