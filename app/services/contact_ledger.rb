# encoding: utf-8
class ContactLedger
  #include Virtus

  #extend ActiveModel::Naming
  #include ActiveModel::Conversion
  #include ActiveModel::Validations
  #include ActiveModel::Validations::Callbacks

  #attribute :account_id    , Integer
  #attribute :currency_id   , Integer
  #attribute :contact_id    , Integer
  #attribute :amount        , Decimal
  #attribute :reference     , String
  #attribute :amount        , Decimal
  #attribute :operation     , String
  #attribute :exchange_rate , Decimal

  ########################################
  # Validations
  #validates_presence_of :contact_id, :contact, :currency_id, :currency, :account_id, :account
  #validates :amount, numericality: { greater_than: 0 }
  #validate  :valid_currency_and_account

  # Callbacks
  #after_validation :set_associations_errors

  attr_reader :account_ledger

  def initialize(attributes)
    @account_ledger = AccountLedger.new(attributes) do |al|
      al.amount = al.amount.abs
      al.exchange_rate = 1
      al.currency_id = al.account_currency_id
    end
  end

  def create_in
    account_ledger.operation = 'in'
  end

  def create_out
    account_ledger.operation = 'in'
    account_ledger.amount = -al.amount
  end

  def persisted
    false
  end

  private
    def contact
      @contact ||= Contact.find_by_id(contact_id)
    end

    def account
      @account ||= Account.find_by_id(account_id)
    end

    def currency
      @currency ||= Currency.find_by_id(currency_id)
    end

    def valid_currency_and_account
      unless account.currency_id == currency_id
        self.errors[:currency_id] << 'La moneda no coincide con la cuenta'
      end
    end

    def set_associations_errors
      [:contact, :currency, :account].each do |met|
        if self.errors[met].any?
          self.errors[met].each {|v| self.errors[:"#{met}_id"] << v }
        end
      end
    end
end
