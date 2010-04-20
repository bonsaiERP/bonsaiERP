class Unit < ActiveRecord::Base
  acts_as_org

  before_save :strip_attributes

  attr_accessible :name, :symbol, :integer

  def integer?
    integer ? I18n.t("yes") : I18n.t("no")
  end

  def strip_attributes
    name.strip!
    symbol.strip!
  end
end
