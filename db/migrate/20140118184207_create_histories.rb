class CreateHistories < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :histories do |t|
        t.integer :user_id
        t.integer :historiable_id
        t.boolean :new_item, default: false
        t.string :historiable_type
        t.text :history_data

        t.datetime :created_at
      end
      add_index :histories, :user_id
      add_index :histories, [:historiable_id, :historiable_type]
      add_index :histories, :created_at
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :histories, :user_id
      remove_index :histories, [:historiable_id, :historiable_type]
      remove_index :histories, :created_at

      drop_table :histories
    end
  end
end
