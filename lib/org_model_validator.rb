# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrgModelValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    klass = options[:class_name] || attribute.to_s.gsub("id", "").classify
    klass = klass.constantize

    object.errors[attribute] << I18n.t("errors.messages.inclusion") unless klass.org.where(attribute => value).any?
  end
end
