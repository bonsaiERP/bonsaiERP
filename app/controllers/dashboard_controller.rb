# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class DashboardController < ApplicationController
  before_filter :authenticate_user!

  def index
    @currency_rates = CurrencyRate.current_hash
  end
end
