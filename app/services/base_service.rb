# encoding: utf-8
class BaseService
  include Virtus.model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  VALID_BOOLEAN = [true, 1, false, 0, "true", "1", "false", "0"]

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
      models.compact.each do |mod|
        mod.errors.each do |k, v|
          if self.respond_to?(k)
            self.errors[k] << v
          else
            self.errors[:base] << v
          end
        end
      end
    end

    # Returns true if calls
    def commit_or_rollback(&b)
      res = true
      ActiveRecord::Base.transaction do
        res = b.call
        raise ActiveRecord::Rollback  unless res
      end

      res
    end
end
