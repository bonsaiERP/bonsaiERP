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


#<VirtualHost *:80>
#   ServerName bonsaierp.com
#   ServerAlias www.bonsaierp.com
#   # !!! Be sure to point DocumentRoot to 'public'!
#   DocumentRoot /home/bonsai/bonsaierp/public
#
#    RewriteEngine on
#    RewriteCond %{HTTP_HOST} ^www\.bonsaierp\.com$ [NC]
#    RewriteRule ^(.*)$ http://bonsaierp.com/$1 [R=301,L]
#
#
#    <IfModule mod_expires.c>
#      # Add correct content-type for fonts
#      AddType application/vnd.ms-fontobject .eot
#      AddType application/x-font-ttf .ttf
#      AddType application/x-font-opentype .otf
#      AddType application/x-font-woff .woff
#      AddType image/svg+xml .svg
#
#      # Compress compressible fonts
