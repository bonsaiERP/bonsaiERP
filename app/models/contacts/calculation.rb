class Contacts::Calculation < Struct.new(:contact)
  delegate :operations, :accounts, to: :contact

  def total_in
    @total_in ||= accounts
    .where{ (accounts.type.in(['Income', 'Loans::Give'])) & (state.eq('approved')) }
    .sum('amount * exchange_rate')
  end

  def total_out
    @total_out ||= accounts
    .where{ accounts.type.in(['Expense', 'Loans::Receive']) & (state.eq('approved'))}
    .sum('amount * exchange_rate')
  end
end
