class TransactionPresenter < ApplicationPresenter

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

  def new_inventory_link
    if @transaction.is_a?(Income) and not(@transaction.delivered?)
      h.link_to "Registrar entrega", 
        url_for(:controller => 'inventory_operation', :action => 'select_store',
                :id => @transaction.id, :operation => 'out'),
        :class => 'new'
    elsif @transaction.is_a?(Buy) and not(@transaction.delivered?)
      h.link_to "Registrar entrega", 
        url_for(:controller => 'inventory_operation', :action => 'select_store',
                :id => @transaction.id, :operation => 'in'),
        :class => 'new'
    end
  end

  def email_link(context)
    if @transaction.income?
      h.link_to "Email", context.new_invoice_email_path(@transaction), :class => 'email ajax', :title => 'Email', 'data-width' => 450
    end
  end

  def render_discount(context)
    context.render "transactions/discount", :transaction => @transaction if @transaction.discounted?
  end

end
