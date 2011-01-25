# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Currency < ActiveRecord::Base

  has_many :organisations
  has_and_belongs_to_many :organisation_currencies, :class_name => 'Organisation', :foreign_key => :organisation_id, :join_table => 'currencies_organisations'
  validates_presence_of :name, :symbol

  def to_s
    %Q(#{symbol} #{name})
  end
end
