# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Transaction::Invoice
  extend ActiveSupport::Concern

  attr_reader :invoice

  included do

  end

  # Saves an invoice
  def save_invoice
    @invoice = true

    set_defaults if self.new_record?
    calc = Transaction::Calculations.new(self)

    self.gross_total = calc.gross_total
    self.total       = calc.total
    self.balance     = calc.balance
    self.discount    = calc.discount
  end

  def is_invoice?
    !!@invoice
  end

  def set_defaults
    self.state ||= 'approved'
    self.cash = true
    self.active = true
    self.exchange_rate ||= 1
    self.currency_id ||= OrganisationSession.currency_id
  end
end
