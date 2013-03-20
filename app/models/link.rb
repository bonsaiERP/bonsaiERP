# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Link < ActiveRecord::Base

  self.table_name = "common.links"

  belongs_to :organisation, inverse_of: :links
  belongs_to :user, inverse_of: :active_links

  validates_presence_of :rol, :organisation, :organisation_id
  validates_inclusion_of :rol, in: User::ROLES
end
