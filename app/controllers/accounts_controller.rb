# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountsController < ApplicationController
  before_filter :check_authorization!

  # GET /accounts/:id
  def show
    @account = Account.org.find(params[:id])
    @ledgers = AccountLedger.filtered(@account.id, params[:option]).order("account_ledgers.created_at desc").page(@page)
    render "/accounts/#{get_view}"
  end

  private
    def get_view
      case @account.accountable.class.to_s
      when "Client", "Supplier", "Staff" then "contact"
      when "Cash" then "cash"
      when "Bank" then "bank"
      end
    end
end
