class Contacts::Query < SimpleDelegator
  def initialize(rel = Contact)
    super(rel)
  end

  def index
    __getobj__
    .select("contacts.*, #{sum_sel 'ai', 'tot_in'}, #{sum_sel 'ae', 'tot_out'}")
    .group('contacts.id')
    .joins("LEFT JOIN accounts ai ON (ai.contact_id = contacts.id) AND ai.type IN ('Income','Loans::Give')")
    .joins("LEFT JOIN accounts ae ON (ae.contact_id = contacts.id) AND ae.type IN ('Expense', 'Loans::Receive')")
  end

  private

    def sum_sel(abbr, tot)
      "sum(#{abbr}.amount * #{abbr}.exchange_rate) AS #{tot}"
    end

end
