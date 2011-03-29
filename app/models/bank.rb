# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Bank < Account
  # callbacks
  after_initialize :set_defaults

  # validations
  validates_presence_of :name, :number
  validates_uniqueness_of :number, :scope => [:name, :organisation_id]

  def to_s
    "#{name} #{number} ( #{currency_name.pluralize} )"
  end

private
  def set_defaults
    self.total_amount ||= 0.0
  end

end
