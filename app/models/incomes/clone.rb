class Incomes::Clone
  attr_reader :income

  CLONE_ATTRS = [:contact_id, :currency, :date, :due_date, :project_id,
                 :description, :total, :exchange_rate]

  delegate(*CLONE_ATTRS, to: :income)

  def initialize(id)
    @income = Income.find id
  rescue
    @income = nil
  end

  def clone
    income ? create_form : Incomes::Form.new_income
  end

  private
    def create_form
      Incomes::Form.new_income(attributes)
    end

    def attributes
      h = Hash.new {|ha, k| ha[k] = send(k) }
      CLONE_ATTRS.each {|v| h[v] }

      h.merge(income_details_attributes: details_attributes)
    end

    def details_attributes
      income.income_details.map do |det|
        {item_id: det.item_id, quantity: det.quantity, price: det.price}
      end
    end
end
