# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CurrencyRate < ActiveRecord::Base
  before_create :update_active

  # relationships
  belongs_to :currency
  belongs_to :organisation

  # validations
  validates_presence_of :currency_id, :organisation_id
  validates :rate, :presence => true, :numericality => {:greater_than => 0}

  scope :current, lambda {|org_id| where(["created_at"])}
  scope :active, where(:active => true)

  # returns if the currency has been updated for the date and organisation
  # @param Integer 
  def self.current?(organisation_id)
    where(["active=? AND organisation_id=? AND created_at>=?", true, organisation_id, Date.today]).any?
  end

  # Prepares a list of CurrencyRate instances
  # @param Organisation organisation
  def self.build_currencies(organisation)
    organisation.currencies.inject([]) {|arr, c| arr << CurrencyRate.new(:currency_id => c.id) }
  end

private
  # sets to inactive all other active currency_rates
  def update_active
    CurrencyRate.update_all(["active=?", false], ["active=? AND currency_id=?", true, currency_id])
    self.active = true
  end

end
