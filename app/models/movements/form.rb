# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::Form < BaseForm
  attribute :id, Integer
  attribute :date, Date
  attribute :due_date, Date
  attribute :contact_id, Integer
  attribute :currency, String
  attribute :exchange_rate, Decimal, default: 1
  attribute :project_id, Integer
  attribute :description, String
  attribute :direct_payment, Boolean, default: false
  attribute :account_to_id, Integer
  attribute :reference, String
  attribute :tax_id, Integer

  ATTRIBUTES = [:date, :contact_id, :total, :currency, :exchange_rate, :project_id, :due_date,
                :description, :direct_payment, :account_to_id, :reference].freeze

  attr_accessor :service, :movement, :ledger, :history

  validates_presence_of :movement
  validates_numericality_of :total
  validate :unique_item_ids

  def create
    set_errors  unless res = service.create(self)
    res
  end

  def create_and_approve
    set_errors  unless res = service.create_and_approve(self)
    res
  end

  def update(attrs = {})
    set_errors  unless res = service.update(self)
    res
  end

  def update_and_approve(attrs = {})
    set_errors  unless res = service.update_and_approve(self)
    res
  end

  def attr_details
    @attr_details || {}
  end

  def set_defaults
    self.date ||= Date.today
    self.due_date ||= Date.today
    self.currency ||= OrganisationSession.currency
  end

  private

    def movement_create_attributes
      attributes.except(:account_to_id, :reference, :direct_payment, :total)
    end

    def movement_update_attributes
      movement_create_attributes.except(:contact_id)
    end

    def unique_item_ids
      UniqueItem.new(self).valid?
    end

    def set_errors
    end
end
