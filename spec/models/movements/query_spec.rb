require 'spec_helper'

describe Movements::Query do
  it "#search SQL" do
    sql = Movements::Query.new(Income).search('ab').to_sql
    expect(sql).to match(/"accounts"."type" IN \('Income'\)/)

    expect(sql).to match(/accounts.name ILIKE '%ab%' OR accounts.description ILIKE '%ab%' OR contacts.matchcode ILIKE '%ab%'/)
  end
end
