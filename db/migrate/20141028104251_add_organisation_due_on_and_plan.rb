class AddOrganisationDueOnAndPlan < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: 'common' do
      add_column :organisations, :due_on, :date
      add_column :organisations, :plan, :string, default: '2users'
    end
  end

  def down
    PgTools.with_schemas only: 'common' do
      remove_column :organisations, :due_on, :date
      remove_column :organisations, :plan, :string
    end
  end
end
