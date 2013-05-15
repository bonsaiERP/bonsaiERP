# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperation < ActiveRecord::Base

  before_create { self.creator_id = UserSession.id }

  OPERATIONS = %w(invin invout invincin invincout invexpin invexpout transin transout).freeze

  belongs_to :store
  belongs_to :contact
  belongs_to :creator, class_name: "User"
  #belongs_to :transout, class_name: "InventoryOperation"
  #belongs_to :store_to, :class_name => "Store"
  belongs_to :project

  #has_one    :transference, :class_name => 'InventoryOperation', :foreign_key => "transference_id"

  has_many :inventory_operation_details, dependent: :destroy
  accepts_nested_attributes_for :inventory_operation_details, allow_destroy: true

  # Validations
  validates_presence_of :ref_number, :store_id, :store, :date
  validates_inclusion_of :operation, in: OPERATIONS

  #validates_presence_of :store_to, :if => :is_transference?

  OPERATIONS.each do |_op|
    define_method :"is_#{_op}?" do
      _op === operation
    end
  end

  #with_options :if => :transout? do |inv|
    #inv.validates_presence_of :store_to
  #end

  def is_transference?
    %w(transin transout).include?(operation)
  end

  # Returns an array with the details fo the transaction
  def get_transaction_items
    transaction.transaction_details
  end

  def self.get_ref_number(op = '')
    ref = InventoryOperation.order("ref_number DESC").limit(1).pluck(:ref_number).first
    year = Date.today.year.to_s[2..4]

    if ref.present?
      _, y, num = ref.split('-')
      if y == year
        "#{op}-#{y}-#{num.next}"
      else
        "#{op}-#{year}-0001"
      end
    else
      "#{op}-#{year}-0001"
    end
  end
end
