class CreateAttachments < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :attachments do |t|
        t.string :attachment_uid
        t.string :title
        t.string :attachable_id
        t.string :attachable_type
        t.integer :position, default: 0

        t.timestamps
      end

      add_index :attachments, [:attachable_id, :attachable_type]
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :attachments, [:attachable_id, :attachable_type]
      drop_table :attachments
    end
  end
end
