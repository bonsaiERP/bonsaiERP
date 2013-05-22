# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventory < ActiveRecord::Base

  before_create { self.creator_id = UserSession.id }

  OPERATIONS = %w(in out inc_in inc_out exp_in exp_out trans_in trans_out).freeze
  IN_OPERATIONS = %w(in inc_in exp_in trans_in)
  OUT_OPERATIONS = %w(out inc_out exp_out trans_out)

  belongs_to :store
  belongs_to :contact
  belongs_to :creator, class_name: "User"
  #belongs_to :transout, class_name: "InventoryOperation"
  #belongs_to :store_to, :class_name => "Store"
  belongs_to :project

  #has_one    :transference, :class_name => 'InventoryOperation', :foreign_key => "transference_id"

  has_many :inventory_details, dependent: :destroy
  accepts_nested_attributes_for :inventory_details, allow_destroy: true,
                                reject_if: lambda {|attrs| attrs[:quantity].blank? || attrs[:quantity] <= 0 }
  alias :details :inventory_details

  # Validations
  validates_presence_of :ref_number, :store_id, :store, :date
  validates_inclusion_of :operation, in: OPERATIONS

  #validates_presence_of :store_to, :if => :is_transference?
  scope :op_in, -> { where(operation: IN_OPERATIONS) }
  scope :op_out, -> { where(operation: OUT_OPERATIONS) }


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

  def is_in?
    IN_OPERATIONS.include? operation
  end

  def is_out?
    OUT_OPERATIONS.include? operation
  end

  def set_ref_number
    io = Inventory.select("id, ref_number").order("id DESC").limit(1).first

    if io.present?
      self.ref_number = get_ref_io(io)
    else
      self.ref_number = "#{op_ref_type}-#{year}-0001"
    end
  end

private
  def get_ref_io(io)
    _, y, _ = io.ref_number.split('-')
    if y === year
      "#{op_ref_type}-#{year}-#{"%04\d" % io.id.next}"
    else
      "#{op_ref_type}-#{year}-0001"
    end
  end

  def year
    @year ||= Date.today.year.to_s[2..4]
  end

  def op_ref_type
    if is_in?
      "I"
    else
      "S"
    end
  end

end
