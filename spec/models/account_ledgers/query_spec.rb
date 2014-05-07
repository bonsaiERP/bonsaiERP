require 'spec_helper'

describe AccountLedger do
  subject { AccountLedgers::Query.new }

  it "#money" do
    sql = <<-SQL
SELECT "account_ledgers".* FROM "account_ledgers" WHERE (("account_ledgers"."account_id" = 1 OR "account_ledgers"."account_to_id" = 1)) ORDER BY account_ledgers.date desc, account_ledgers.id desc
    SQL

    expect(subject.money(1).to_sql.squish).to eq(sql.squish)
  end

  it "#search" do
    sql = <<-SQL
SELECT "account_ledgers".* FROM "account_ledgers"  WHERE (accounts.name ILIKE '%ba%' OR account_tos_account_ledgers.name ILIKE '%ba%' OR contacts.matchcode ILIKE '%ba%')
    SQL

    expect(subject.search('ba').to_sql.squish).to eq(sql.squish)
  end
end
