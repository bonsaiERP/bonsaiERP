# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountsController < ApplicationController
  before_filter :check_authorization!

  # GET /accounts/:id
  def show
    @account = Account.org.find(params[:id])
    @ledgers = @account.account_ledgers.filtered(params[:option]).order("account_ledgers.date desc").page(@page)
    @partial = get_partial
  end

  private
    def get_partial
      case @account.accountable.class.to_s
      when "Client", "Supplier", "Staff" then "contact"
      when "Cash", "Bank" then "bank"
      end
    end
end
