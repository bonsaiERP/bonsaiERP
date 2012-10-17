class AddUsersAuthToken < ActiveRecord::Migration
  def up
    change_table 'common.users' do |t|
      t.string :auth_token
    end
    add_index 'common.users', :auth_token
  end

  def down
    change_table 'common.users' do |t|
      t.remove :auth_token
    end
  end
end
