# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountsController < ApplicationController
  before_filter :check_authorization!

  # GET /accounts/:id
  def show
    @account = Account.org.find(params[:id])

    set_list
    #@ledgers = AccountLedger.filtered(@account.id, params[:option]).order("account_ledgers.created_at desc").page(@page)
    render "/accounts/#{get_view}"
  end

  private
    def set_list
      params[:tab] ||= "transactions"

      case params[:tab]
      when "incomes"
        @partial = "incomes"
        @locals = {
          :incomes => @account.incomes, :currency_rates => CurrencyRate.current_hash, :account => @account
        }
      when "buys"
      when "expenses"
      else
        @partial = "account_ledgers/money"
        @locals = {
          :ledgers => AccountLedger.filtered(@account.id, params[:option]).order("account_ledgers.created_at desc").page(@page),
          :account => @account 
        }
      end
    end

    def get_view
      case @account.accountable.class.to_s
      when "Client", "Supplier", "Staff" then "contact"
      when "Cash" then "cash"
      when "Bank" then "bank"
      end
    end
end
