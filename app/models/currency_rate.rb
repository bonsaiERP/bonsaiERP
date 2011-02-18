# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class CurrencyRate < ActiveRecord::Base
  acts_as_org

  before_create :update_active

  # relationships
  belongs_to :currency
  belongs_to :organisation

  # validations
  validates_presence_of :currency_id, :organisation_id
  validates :rate, :presence => true, :numericality => {:greater_than => 0}

  # scopes
  #default_scope where(:organisation_id => OrganisationSession.organisation_id)
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

  # Method to create new currencies
  def self.create_currencies(values)
    values = values.map{ |v| v.last } if values.is_a? Hash
    created_currencies = []
    CurrencyRate.transaction do
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

private
  # sets to inactive all other active currency_rates
  def update_active
    CurrencyRate.update_all(["active=?", false], ["active=? AND currency_id=? AND organisation_id=?", true, currency_id, OrganisationSession.organisation_id])
    self.active = true
  end

end
