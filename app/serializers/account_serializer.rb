# encoding: utf-8
class AccountSerializer < ActiveModel::Serializer
  attributes :id, :type, :currency, :amount, :name, :to_s
end

