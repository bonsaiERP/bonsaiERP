class Contacts::Calculation < Struct.new(:contact)
  delegate :operations, :accounts, to: :contact

  def total_in
    @total_in ||= accounts.in.approved.sum('amount * exchange_rate')
  end

  def total_out
    @total_out ||= accounts.out.approved.sum('amount * exchange_rate')
  end
end
