class Contacts::Query < SimpleDelegator
  def initialize(rel = Contact)
    super(rel)
  end

  def index
    __getobj__
    .select("contacts.*, tot_in, tot_out")
    .joins("LEFT JOIN (#{tots_sql}) AS res ON (res.contact_id=contacts.id)")
  end

  private

    def tots_sql
      <<-SQL
SELECT contact_id, SUM(tot_in) as tot_in, SUM(tot_out) AS tot_out FROM(
  SELECT contact_id, amount*exchange_rate AS tot_in, 0 as tot_out
  FROM accounts
  WHERE type IN ('Income','Loans::Give') AND state='approved'
  UNION
  SELECT contact_id, 0 AS tot_in, amount*exchange_rate AS tot_out
  FROM accounts
  WHERE type IN ('Expense','Loans::Receive') AND state='approved'
) AS res GROUP BY contact_id
      SQL
    end

end
