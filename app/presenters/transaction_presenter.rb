class TransactionPresenter

  def initialize(transaction)
    @transaction = transaction
  end

  def email_link
    #content_tag(:div, "Hola")
    "Hola"
    #link_to "Uno", "/si"
    #link_to("Email", new_invoice_email_path(@transaction), :class => 'email ajax', :title => 'Email', 'data-width' => 450)
  end

end
