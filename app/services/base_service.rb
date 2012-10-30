# encoding: utf-8
class BaseService
  include Virtus

  attr_reader :errors

  def initialize(attributes = {})
    super attributes
    @errors = ActiveModel::Errors.new(self)
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
