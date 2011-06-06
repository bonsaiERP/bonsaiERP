# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class MoneyStore < ActiveRecord::Base

  acts_as_org

  # delegations
  delegate :name, :symbol, :code, :plural, :to => :currency, :prefix => true

  # Creates methods to determine if is bank?, cash?
  %w[bank cash].each do |t|
    class_eval <<-CODE, __FILE__, __LINE__ +1
      def #{t}?
        self.class.to_s.downcase == "#{t}"
      end
    CODE
  end

private
  def create_account

  end
end
