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

f = File.new 'app/views/layouts/_print_css.print.erb', 'w+'
f.write css
f.close
