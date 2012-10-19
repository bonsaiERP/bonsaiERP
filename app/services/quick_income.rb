# encoding: utf-8
# Generates a quick income with all data
class QuickIncome
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :income, :account_ledger

  attribute :ref_number  , String
  attribute :currency_id , Integer
  attribute :account_id  , Integer
  attribute :contact_id  , Integer
  attribute :date        , Date
  attribute :bill_number , String
  attribute :fact        , Boolean

  def initialize(attributes = {})
    super attributes
    self.ref_number = ref_number || Income.get_ref_number
    self.fact = [true, false].include?(fact) ? fact : true
    self.date = date || Date.today
  end

  def create
    ActiveRecord::Base.transaction do
      create_income
      
      create_account_ledger
    end
    
    income.persisted? && account_ledger.persisted?
  end

  private
    def create_income
      @income = Income.create!(income_attributes) do |inc|
      end
    end

    def income_attributes
      {ref_number: ref_number, date: date, currency_id: currency_id, 
       bill_number: bill_number, fact: fact }
    end

    def create_account_ledger
    end
end
