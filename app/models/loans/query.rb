class Loans::Query
  def all_loans
    Account.where(type: %w(Loans::Receive Loans::Give))
    .includes(:contact, :creator, :updater)
  end
end
