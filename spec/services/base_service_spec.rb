require 'spec_helper'

describe BaseService do
  subject { BaseService.new }

  it { should_not be_persisted }
  it "Uses ActiveModel::Errors for errors" do
    subject.errors.should be_is_a(ActiveModel::Errors)
  end

  context "Check commit rollback" do
    subject do
      class TestRollback < BaseService
        attr_accessor :value
        def test_roll
          commit_or_rollback { value }
        end

        def test_block(&b)
          commit_or_rollback { b.call }
        end
      end

      TestRollback.new
    end

    #it "rollbacks value" do
      #subject.value = false

      #expect { subject.test_roll }.to raise_error(ActiveRecord::Rollback)
    #end

    #it "saves" do
      #subject.value = true
      #subject.test_roll

      #line = `tail -n 3 log/test.log`
      #line.should_not =~ /ROLLBACK/
    #end

    #it "saves with block" do
      #subject.value = true
      #subject.test_block do
        #puts "Call and then"
        #true && true
      #end

      #line = `tail -n 1 log/test.log`
      #line.should_not =~ /ROLLBACK/
    #end

    #it "rollbacks with block" do
      #subject.value = true
      #subject.test_block do
        #puts "Call and then false"
        #false && false
      #end

      #line = `tail -n 1 log/test.log`
      #line.should =~ /ROLLBACK/
    #end
  end
end
