# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Buy < Transaction

  ########################################
  # Includes
  include Transaction::TransactionDetails
  ########################################


  attr_accessible  :ref_number,  :date,                          :contact_id,
                   :project_id,  :currency_id,                   :exchange_rate,
                   :bill_number, :taxis_ids,                     :description,
                   :transaction_details_attributes,              :fact

  ########################################
  # Validations
  validates             :ref_number,           :presence => true , :uniqueness => true
  validate              :valid_number_of_items

  scope :inventory, where("transactions.state NOT IN (?) AND delivered = ?", ['draft', 'nulled'], false)

  def to_s
    "Compra #{ref_number}"
  end

  def get_ref_number
    refs            = Buy.order("ref_number DESC").limit(1)
    refs.any? ? refs.first.ref_number.next : "C-#{Date.today.year}-0001"

  end

  # Set some parameters to save a buy
  def save_trans
    self.discount = 0
    self.taxis_ids = []

    super
  end

private
  # Initialized  the ref_number
  def set_ref_number
    if ref_number.blank?
      self.ref_number = get_ref_number
    end
  end
end
