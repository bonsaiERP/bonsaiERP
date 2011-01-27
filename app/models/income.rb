# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Income < Transaction
  acts_as_org
  
  # callbacks
  before_create :set_state
  before_create :create_first_pay_plan

  STATES = ["draft", "aproved", "payed"]


  attr_accessible :ref_number, :date, :contact_id,
                  :project_id, :currency_id, :currency_exchange_rate,
                  :discount, :bill_number, :taxis_ids,
                  :description, :transaction_details_attributes


  #accepts_nested_attributes_for :transaction_details, :allow_destroy => true
  #validations
  validates_presence_of :ref_number, :date

  # Presents a localized name for state
  def show_state
    case I18n.locale
    when :es
      ["Borrador", "Aprobado", "Pagado"]
    end    
  end

  def aproved?
    self.state != "draft"
  end

private
  def set_state
    self.state = STATES.first
  end

  # Creates the first payment for cash payments
  def create_first_pay_plan
    pay_plan = self.pay_plans.build(:currency_id => currency_id, :amount => total, :ctype => self.class.to_s,
                                   :interests_penalties => 0, :payment_date => self.date,
                                   :alert_date => self.date, :email => false )
    pay_plan.save
  end
end
