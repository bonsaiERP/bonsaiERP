# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction

  ########################################
  # Includes
  include Transaction::TransactionDetails
  ########################################

  belongs_to :deliver_approver, :class_name => "User"

  #relationships

  # Accessible attributes
  attr_accessible  :ref_number,  :date,                          :account_id,
                   :project_id,  :currency_id,                   :exchange_rate,
                   :discount,    :bill_number,                   :taxis_ids,
                   :description, :transaction_details_attributes, :contact_id,
                   :fact,        :created_at


  #validations
  validates             :ref_number,           :presence => true , :uniqueness => true

  # Scopes
  scope :sum_total_balance, approved.select("SUM(balance * exchange_rate) AS total_bal").first[:total_bal]
  scope :discount, where(:discounted => true)

  def to_s
    "Venta #{ref_number}"
  end

  def get_ref_number
    refs            = Income.order("ref_number DESC").limit(1)
    refs.any? ? refs.first.ref_number.next : "V-#{Date.today.year}-0001"
  end

  # Approves deliver in case that the sale is credit
  def approve_deliver
    return false if draft?
    return false unless credit?
    
    self.deliver = true
    self.deliver_approver_id = UserSession.user_id
    self.deliver_datetime    = Time.zone.now
    self.save
  end

  private
  def set_defaults_with_details
    set_defaults
    transaction_details.build(price: 0, quantity: 0)
  end

  # Initialized  the ref_number
  def set_ref_number
    if ref_number.blank?
      self.ref_number = get_ref_number
    end
  end

  def set_client
    contact.update_attribute(:client, true)
  end
end
