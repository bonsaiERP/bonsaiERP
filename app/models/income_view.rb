class IncomeView < ActiveRecord::Base
  self.table_name = 'incomes_view'
  belongs_to :contact
end
