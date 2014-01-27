class CreateStores < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :stores do |t|
        t.string :name
        t.string :address
        t.string :phone
        t.boolean :active, :default => true
        t.string :description

        t.timestamps
      end
    end
  end
end
