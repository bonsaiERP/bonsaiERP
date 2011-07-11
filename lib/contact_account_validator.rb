# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactAccountValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    object.errors[attribute] << I18n.t("errors.messages.inclusion") unless Account.org.where(:id => value, :original_type => ['Client', 'Supplier', 'Staff']).any?
  end
end

