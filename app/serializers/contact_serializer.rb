# encoding: utf-8
class ContactSerializer < ActiveModel::Serializer
  attributes :id, :matchcode, :first_name, :last_name, :to_s
end
