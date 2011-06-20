# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module  Models::Account
  module ServiceAccount
    private

      def create_new_account
        ac = AccountType.org.scoped_by_account_number("Service").first
        self.build_account(
          :currency_id => OrganisationSession.currency_id,
          :account_type_id => ac.id
        ) {|a| 
          a.amount = 0
          a.initial_amount = 0
        }
      end

  end
end

