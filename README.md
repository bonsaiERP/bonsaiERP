# *bonsaiERP*
*bonsaiERP* is a simple ERP system to control the most basic stuff for a company, that includes:

- Sales
- Buys
- Expenses
- Bank accounts
- Inventory

 The software is been improved as we move

ctags -R `bundle show rails`/../*

v=spf1 a ip4:192.34.56.117 -all

txt.gsub(/(<link href=)"([a-z\.\/\?=])"/, "#{$1}\"localhost.bom:9292#{$2}\"")
render_to_string

txt.gsub(/(<link href=")([a-z0-9\/\?\.=\-_]+)/) { "#{$1}http://localhost.bom:9292#{$2}\"" }S

//= require 'plugins/bootstrap3'
//= require 'components/print_common'
//= require 'clases'
css = "<style>\n"
%w(plugins/bootstrap3 components/print_common clases).each do |v|
  css << Rails.application.assets.find_asset(v).body
end
css << '</style>'

IMPORTANT

add_index :accounts, :tax_in_out # Needs onserver index


add_index :accounts, :creator_id
add_index :accounts, :approver_id
add_index :accounts, :nuller_id
add_index :accounts, :due_date

add_index :accounts, :extras, using: :gist

add_index :account_ledgers, :contact_id

ActiveRecord::Migrator.migrations('db/migrate').map {|v| "('#{v.version}')" }.join(', ')

```
cp -r vendor/assets/stylesheets/bonsaierp/fonts public/assets/
cp app/assets/images/browser_logos.png public/assets
cp app/assets/images/ajax-loder.gif public/assets
```

{
  "name": "My App",  // will be displayed under the screenshot
  "thumb": "my-app/thumb.png", // path to the image (omit the projects/ prefix)
  "desc": "Description of your app", // One or two sentences
  "url": "http://myapp.com", // url to your app
  "info": "http://myapp.com/blog", // url to app announcement or background
  "src": "https://github.com/me/myapp", // (optional) Url to your source repository
  "submitter": "IgorMinar", // your github username
  "submissionDate": "2012-05-24", // current date in ISO format
  "tags": [
    "Demo", "Production", "Toy" // choose your app seriousness level (for plunks or fiddles use "Toy")
    "Game", "CRUD", "Entertainment", "Productivity", ... // choose your app type
    "Animations", "Local Storage", "Audio Api", "AppCache", ... // features and technologies
    "No jQuery", "jQuery" // do you use jQuery?
    "Open Source", // tag open source projects
    "Tests Included" // use if open source and tests are included
    ... // others?
  ]
}

427px
