# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :client_account do
    name "MyString"
    users 1
    agencies 1
    branding false
    disk_space 1
    backup "MyString"
    stored_backups 1
    api false
    report false
    third_party_apps false
  end
end
