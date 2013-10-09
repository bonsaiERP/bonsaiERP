class CreateTaxes < ActiveRecord::Migration
  def change
    PgTools.with_schemas only: 'public' do
      create_table :taxes do |t|
        t.string :name, limit: 100
        t.string :abreviation, limit: 20
        t.decimal :percentage, precision: 5, scale: 2, default: 0.0

        t.timestamps
      end
    end
  end
end
