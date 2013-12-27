# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Loans::Form < BaseForm
  attribute :contact_id, Integer
  attribute :account_to_id, Integer
  attribute :date, Date
  attribute :due_date, Date
  attribute :total, Decimal, default: 0
  attribute :reference, String
  attribute :description, String
  attribute :exchange_rate, Decimal, default: 1

  #attr_accessor :klass, :ledger_sign, :ledger_operation

  delegate :currency, to: :account_to, prefix: true, allow_nil: true
  delegate :name, :id, to: :loan

  # validations
  validates_presence_of :account_to_id, :account_to, :reference
  validates :exchange_rate, numericality: { greater_than: 0 }


  def contact
    @contact ||= Contact.find_by(id: contact_id)
  end

  private

    def account_to
      @account_to ||= Account.active.money.find_by(id: account_to_id)
    end

end
