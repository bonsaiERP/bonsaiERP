# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Unit < ActiveRecord::Base

  # callbacks
  before_save    :strip_attributes
  before_update  :update_item_units
  before_destroy :check_items_destroy

  # Relationships

  has_many :items

  # Validations
  validates_presence_of :name, :symbol
  validates_uniqueness_of :symbol, :name
  validates_lengths_from_database

  scope :invisible, -> { where(visible: false) }

  def to_s
    "#{name} (#{symbol})"
  end

  def integer?
    # integer ? I18n.t("yes") : I18n.t("no")
    integer ? "Si" : "No"
  end

  def self.create_base_data
    path = File.join(Rails.root, "db/defaults", "units.#{I18n.locale}.yml")
    data = YAML.load_file(path)
    Unit.create!(data)
  end

  private

    def strip_attributes
      name.strip!
      symbol.strip!
    end

    # Returns false if there are
    def check_items_destroy
      if Item.where(:unit_id => id).any?
        errors.add(:base, "Existen items que usan esta unidad de medidad")
        false
      else
        true
      end
    end

    def update_item_units
      if name_changed? || symbol_changed?
        Item.where(unit_id: id).update_all(["unit_name=?, unit_symbol=?", name, symbol])
      end
    end

end
