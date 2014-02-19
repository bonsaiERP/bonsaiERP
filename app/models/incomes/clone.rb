# Creates or new instance with the parameters form an income or
# creates a new one in case that no id is given
class Incomes::Clone
  attr_reader :income

  CLONE_ATTRS = [:contact_id, :currency, :date, :due_date, :project_id,
                 :description, :total, :exchange_rate]

  delegate(*CLONE_ATTRS, to: :income)
  delegate :income_details, to: :income

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
      hash = Hash.new { |ha, key| ha[key] = send(key) }
      CLONE_ATTRS.each { |attr| hash[attr] }

      hash.merge(income_details_attributes: details_attributes)
    end

    def details_attributes
      income_details.map { |det| det.slice(*%w(item_id quantity price)) }
    end
end
