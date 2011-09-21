class TransactionPresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper 

  def initialize(transaction)
    @transaction = transaction
  end

  def approve_deliver?(ses)
    return false unless User::ROLES.slice(0,2).include? ses[:user][:rol]

    if @transaction.is_a?(Income) and @transaction.credit? and not(@transaction.deliver?)
      true
    else
      false
    end
  end

  def email_link
    #content_tag(:div, "Hola")
    "Hola"
    #link_to "Uno", "/si"
    #link_to("Email", new_invoice_email_path(@transaction), :class => 'email ajax', :title => 'Email', 'data-width' => 450)
  end

end
