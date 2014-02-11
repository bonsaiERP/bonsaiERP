require 'spec_helper'
require 'action_view'
require 'resubject/rspec'
#require 'presenters/base_presenter'

describe LedgerOperationPresenter do
  it "hola" do
    al = build :account_ledger, account_id: 1, account_to_id: 2
    h = LedgerOperationPresenter.new(al, ActionView::Base.new)

  end
end
