# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
#
# Model that can be included to create and account in other models
module Models::Account::CreateAccount
  extend ActiveSupport::Concern

  included do
    before_save :create_account
  end

  module InstanceMethods

  private
    def create_account
      Account.new(:name => self.to_s, :account_type)
    end
  end
end
