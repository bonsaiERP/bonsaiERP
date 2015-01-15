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
  attribute :tax_in_out, Boolean, default: false # true = out, false = in
  # Tags
  attribute :tag_ids, Array

  ATTRIBUTES = [:date, :contact_id, :currency, :exchange_rate, :project_id, :due_date,
                :description, :direct_payment, :account_to_id, :reference].freeze

  attr_accessor :service, :movement, :history

  validates_presence_of :movement
  validates_numericality_of :total
  validate :unique_item_ids

  delegate :ref_number, to: :movement
  delegate :ledger, to: :service

  def create
    set_errors(movement)  unless res = service.create(self)
    res
  end

  def create_and_approve
    set_errors(movement, ledger)  unless res = service.create_and_approve(self)
    res
  end

  def update(attrs = {})
    self.attributes = attrs
    set_errors(movement, ledger)  unless res = service.update(self)
    res
  end

  def update_and_approve(attrs = {})
    self.attributes = attrs
    set_errors(movement, ledger)  unless res = service.update_and_approve(self)
    res
  end

  def attr_details
    @attr_details || {}
  end

  def set_defaults
    _today = Time.zone.now.to_date
    self.date ||= _today
    self.due_date ||= _today
    self.currency ||= OrganisationSession.currency
  end

  def form_details_data
    dets = movement.new_record? ? movement.details : movement.details.includes(:item)
    dets.map { |v|
      {
        id: v.id, item: v.item_to_s, item_id: v.item_id,
        unit_symbol: v.unit_symbol, unit_name: v.unit_name,
        price: v.price, quantity: v.quantity,
        original_price: v.item_price, errors: v.errors
      }
    }
  end

  def get_movement_attributes
    movement.attributes
  end

  private

    def unique_item_ids
      UniqueItem.new(self).valid?
    end

end
