# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrganisationRelationValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    attribute = attribute.to_s[0...-3]
    _klass = object.class.reflections[attribute.to_sym]
    _klass = _klass.options[:class_name] || attribute.classify
    unless _klass.constantize.org.find_by_id(value)
      object.errors[:"#{attribute}"] << I18n.t("errors.messages.invalidkeys")
    end
  end
end


