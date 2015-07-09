class Loans::Query
  def self.all_loans
    Account.where(type: %w(Loans::Receive Loans::Give))
    .includes(:contact, :creator, :updater)
  end

  def self.filter(args = {})
    loans = loan_type(args)

    loans = loans.joins(:contact).where("contacts.matchcode ILIKE ?", "%#{args[:search]}%")   if args[:search].present?

    loans = loans.includes(:contact, :creator, :updater)

    loans
  end

  def self.loan_type(args = {})
    case args[:type].to_s
    when "all", ""
      Account.where(type: %w(Loans::Receive Loans::Give))
    when "give"
      Account.where(type: "Loans::Give")
    when "receive"
      Account.where(type: "Loans::Receive")
    end
  end
end
