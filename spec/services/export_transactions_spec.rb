require 'spec_helper'

describe ExportTransactions do
  it "validate" do
    exp = ExportTransactions.new(date_start: '2013-05-01', date_end: '2013-05-31')
    exp.should be_valid


    exp = ExportTransactions.new(date_start: '2013-05-01', date_end: '2013-04-01')

    exp.should_not be_valid


    exp = ExportTransactions.new(date_start: '2013-05', date_end: '2013-05-31')
    exp.should_not be_valid

    exp = ExportTransactions.new(date_start: '2013-05-01', date_end: 'je')
    exp.should_not be_valid
  end
end
