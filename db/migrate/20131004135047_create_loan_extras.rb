class CreateLoanExtras < ActiveRecord::Migration
  def change
    PgTools.with_schemas except: 'common' do
      create_table :loan_extras do |t|
        t.integer :step, default: 1
        t.integer :loan_id, null: false
        t.index   :loan_id, unique: true
        t.integer :account_id, null: false
        t.index   :account_id
        t.date :due_date, null: false, index: true
        t.decimal :total, null: false
        t.decimal :interests, default: 0
      end
    end
  end
end
