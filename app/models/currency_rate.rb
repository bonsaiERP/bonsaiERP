# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CurrencyRate < ActiveRecord::Base

  before_create :update_active

  # relationships
  belongs_to :currency

  # validations
  validates_presence_of :currency_id
  validates :rate, :presence => true, :numericality => {:greater_than => 0}

  delegate :name, :symbol, :code, :to => :currency, :prefix => true

  # scopes
  scope :active, where(:active => true)

  # returns if the currency has been updated for the date and organisation
  # @param Integer 
  def self.current?(org)
    if org.currency_ids.any?
      CurrencyRate.org.where(["active=? AND created_at>=?", true, Date.today]).any?
    else
      true
    end
  end

  # Creates a Hash of the currency_rates
  def self.current_hash
    Hash[ CurrencyRate.active.map {|cr| [cr.currency_id, cr.rate] } ]
  end

  # Method to create new currencies
  def self.create_currencies(values)
    values = values.map{ |v| v.last } if values.is_a? Hash
    created_currencies = []
    CurrencyRate.transaction do
      CurrencyRate.update_all(["active=?", false], ["active=?", true])
      created_currencies = CurrencyRate.create(values)
      raise ActiveRecord::Rollback if created_currencies.map(&:id).include?(nil)
    end
    created_currencies
  end

  # Prepares a list of CurrencyRate instances
  # @param Organisation organisation
  def self.build_currencies(organisation)
    organisation.currencies.inject([]) {|arr, c| arr << CurrencyRate.new(:currency_id => c.id) }
  end

  def self.json
    hash = {}
    CurrencyRate.active.includes(:currency).each do |ac| 
      arr = json_fields.zip( json_fields.map {|val| ac.send(val) } )
      hash[ac.currency_id] = Hash[ arr ]
    end
    hash
  end

  def self.json_fields
    [:rate, :currency_name, :currency_symbol, :currency_code]
  end

private
  # sets to inactive all other active currency_rates
  def update_active
    CurrencyRate.update_all(["active = ?", false], ["active = ? AND currency_id = ?", true, id])
    self.active = true
  end

end
