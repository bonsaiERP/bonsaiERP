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

lHost *:80>
ServerName bonsaierp.com
    ServerAlias     www.bonsaierp.com
# !!! Be sure to point DocumentRoot to 'public'!
        DocumentRoot /home/bonsai/bonsaierpsite/public

    # XSendFile On
    # XSendFilePath /tmp

<Directory /somewhere/public>
# This relaxes Apache security settings.
AllowOverride all
# MultiViews must be turned off.
Options -MultiViewsMultiViews
</Directory>

    <IfModule mod_expires.c>
      # Add correct content-type for fonts
      AddType application/vnd.ms-fontobject .eot
      AddType application/x-font-ttf .ttf
      AddType application/x-font-opentype .otf
      AddType application/x-font-woff .woff
      AddType image/svg+xml .svg

      # Compress compressible fonts
      AddOutputFilterByType DEFLATE application/x-font-ttf
application/x-font-opentype image/svg+xml

      ExpiresActive on

  ExpiresByType image/jpg "access plus 1 month"
  ExpiresByType image/jpeg "access pluss 1 month"
  ExpiresByType image/gif "access plus 1 month"
  ExpiresByTypesByType image/png "access plus 1 month"
  ExpiresByType image/x-icon    "access plus 1 month"
  ExpiresByType text/css "access plus 1 month"
      ExpiresByType text/javascript "access plus 1 month"
  ExpiresByTypepe application/x-javascript "access plus 1 month"
  ExpiresByType approver_idlication/javascript "access plus 1 month"

      # Add a far future Expires header for fonts
      ExpiresByType application/vnd.ms-fontobject "access plus 1 month"
      ExpiresByType application/x-font-ttf "access plus 1 month"
      ExpiresByType application/x-font-opentype "access plus 1 month"
      ExpiresByType application/x-font-woff "access plus 1 month"
      ExpiresByType image/svg+xml "access plus 1 month"
</IfModule>
</VirtualHost>

<VirtualHost *:80>
ServerName app.bonsaierp.com
    ServerNamerAlias *.bonsaierp.com
# !!! Be sure to point DocumentRoot to 'public_schema?'!
DocumentRoot /home/bonsai/bonsaierp/public

    # XSendFile On
       # XSendFilePath /tmp

<Directory /somewhere/public>
# This relaxes Apache security settings.
AllowOverride all
# MultiViews must be ttfurned off.
Options -MultiViews
</Directory>

    <IfModule mod_expires.c>
      # Add correct content-type for fonts
      AddType application/vnd.ms-fontobject .eot
      AddType application/x-font-ttf .ttf
      AddType application/x-font-opentype .otf
      AddType application/x-font-woff .woff
      AddType image/svg+xml .svg

      # Compress compressible fonts
      AddOutputFilterByType DEFLATE application/x-font-ttf
application/x-font-opentype image/svg+xml

      ExpiresActive on

  ExpiresByType image/jpg "access plus 1 month"
  ExpiresByType image/jpeg "access        plus 1 month"
  ExpiresByType image/gif "access plus 1 month"
  ExpiresByTypepeiresByType image/png "access plus 1 month"
  ExpiresByType image/x-IconsHelperon "access plus 1 month"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType text/javascript "access plus 1 month"
  ExpiresByTypesByTypeyType application/x-javascript "access plus 1
month"
  ExpiresByType     application/javascript "access plus 1 month"

      # Add a far future Expires header for fonts
      ExpiresByType application/vnd.ms-fontobject "access plus 1 month"
      ExpiresByType application/x-font-ttf "access plus 1 month"
      ExpiresByType application/x-font-opentype "access plus 1 month"
      ExpiresByType application/x-font-woff "access plus 1 month"
      ExpiresByType image/svg+xml "access plus 1 month"
</IfModule>
</VirtualHost>
    ""
