# encoding: utf-8
class BaseService
  include Virtus
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :errors

  def initialize(attributes = {})
    super attributes
    @errors = ActiveModel::Errors.new(self)
  end

  def persisted?
    false
  end

private
  def set_errors(*models)
    models.each do |mod|
      next unless self.send(mod).present?

      self.send(mod).errors.each do |k, v|
        if self.respond_to?(k)
          self.errors[k] << v
        end
      end
    end
  end
end
