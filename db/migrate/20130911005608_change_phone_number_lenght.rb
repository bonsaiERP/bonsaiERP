class ChangePhoneNumberLenght < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: ['common', 'public'] do
      change_column :organisations, :phone, :string, limit: 40
      change_column :organisations, :phone_alt, :string, limit: 40
      change_column :organisations, :mobile, :string, limit: 40

      change_column :users, :phone, :string, limit: 40
      change_column :users, :mobile, :string, limit: 40
    end

    PgTools.with_schemas except: 'common' do
      change_column :contacts, :phone, :string, limit: 40
      change_column :contacts, :mobile, :string, limit: 40

      change_column :stores, :phone, :string, limit: 40
    end
  end
end
