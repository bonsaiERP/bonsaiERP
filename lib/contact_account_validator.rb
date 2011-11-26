# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactAccountValidator < ActiveModel::EachValidator

  def validate_each(object, attribute, value)
    clases = options[:clases] || ['Client', 'Supplier', 'Staff']
    object.errors[attribute] << I18n.t("errors.messages.inclusion") unless Account.where(:id => value, :original_type => clases).any?
  end
end

