# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    object.errors[attribute] << I18n.t("errors.messages.inclusion") unless Contact.org.where(:id => value).any?
  end
end


