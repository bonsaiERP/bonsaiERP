class CreateAttachments < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :attachments do |t|
        t.string :attachment_uid
        t.string :name
        t.integer :attachable_id
        t.string :attachable_type
        t.integer :user_id
        t.integer :position, default: 0
        t.boolean :image, default: false
        t.integer :size
        t.json :image_attributes

        t.timestamps
      end

      add_index :attachments, [:attachable_id, :attachable_type]
      add_index :attachments, :user_id
      add_index :attachments, :image
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :attachments, [:attachable_id, :attachable_type]
      remove_index :attachments, :image
      drop_table :attachments
    end
  end
end
