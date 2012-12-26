# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction

  ########################################
  # Callbacks
  before_create :set_client

  ########################################
  # Relationships
  belongs_to :deliver_approver, :class_name => "User"

  ########################################
  # Validations
  validates             :ref_number,           :presence => true , :uniqueness => true

  ########################################
  # Scopes
  scope :sum_total_balance, approved.select("SUM(balance * exchange_rate) AS total_bal").first[:total_bal]
  scope :discount, where(:discounted => true)

  def to_s
    "Ingreso #{ref_number}"
  end

  def self.defaults
    super.merge(ref_number: Income.get_ref_number)
  end

  def self.get_ref_number
    ref = Income.order("ref_number DESC").first
    ref.present? ? ref.ref_number.next : "I-0001"
  end

private
  def set_client
    if contact.present? && !contact.client?
      contact.update_attribute(:client, true)
    end
  end

end
