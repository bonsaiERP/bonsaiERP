class Tax < ActiveRecord::Base

  # callbacks
  belongs_to :organisation

  #validations
  validates_presence_of :name, :abbreviation
  validates_numericality_of :rate, :greater_than_or_equal_to => 0
  validates_numericality_of :rate, :less_than_or_equal_to => 100
  validates_associated :organisation

end
