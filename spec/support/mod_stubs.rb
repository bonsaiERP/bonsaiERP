# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module ModStubs
  class << self
    def stub_account_type(data)
      data = data.merge(:name => data[:name] || data[:account_number].downcase)

      a = AccountType.new(data) {|a| 
        a.id = data[:id] || 1
        a.account_number = data[:account_number]
      }

      fake = Object.new
      fake.stubs(:scoped_by_account_number).with(data[:account_number]).returns([a])
      AccountType.stubs(:org => fake)
    end
  end
end
