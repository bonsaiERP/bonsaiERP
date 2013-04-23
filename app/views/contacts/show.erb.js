<% if params[:income] %>
  $('<%= escape_javascript @contact.incomes(@page) %>').appendTo('#incomes ul')
<% else if params[:expense] %>
  $('<%= escape_javascript @contact.incomes(@page) %>').appendTo('#expenses ul')
