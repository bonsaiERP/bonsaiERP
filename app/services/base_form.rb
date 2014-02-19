# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class BaseForm
  include Virtus.model
  #include ActiveModel::Model
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  VALID_BOOLEAN = [true, 1, false, 0, "true", "1", "false", "0"]

  attr_reader :has_error#:errors,

  def initialize(attributes = {})
    super attributes
    @errors = ActiveModel::Errors.new(self)
  end

  def persisted?
    false
  end

  private
    def has_error?
      !!@has_error
    end

    def set_has_error
      @has_error = true
    end

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

