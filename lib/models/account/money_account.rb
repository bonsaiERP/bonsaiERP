# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module  Models::Account
  module MoneyAccount
    private

    def create_new_account
      self.build_account(
        :currency_id => self.currency_id,
        :account_type_id => AccountType.org.scoped_by_account_number(self.class.to_s).first.id
      ) {|a|
        a.amount = amount
        a.initial_amount = amount
        a.organisation_id = OrganisationSession.organisation_id
        a.original_type = self.class.to_s
      }
    end

  end
end
