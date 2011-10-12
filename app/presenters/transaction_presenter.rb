# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionPresenter < BasePresenter
  presents :transaction

  def edit_link
    h.link_to "Editar", "/#{h.params[:controller]}/#{transaction.id}/edit", :class => 'edit' if allow_action?
  end

  def null_link
    h.link_to 'Anular', transaction, :class => 'delete', :confirm => 'Esta seguro de anular?'
  end

  def approve_deliver?
    return false unless User::ROLES.slice(0,2).include? h.session[:user][:rol]

    if transaction.is_a?(Income) and transaction.credit? and not(transaction.deliver?)
      true
    else
      false
    end
  end

  def currency
    unless h.currency_id === transaction.currency_id
      content_tag(:h3, :class => 'black') do
        "#{h.currency_symbol} 1 = #{transaction.currency_symbol} #{ntc transaction.exchange_rate, :precision => 4}"      
      end
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

  def email_link
    if transaction.income?
      h.link_to "Email", h.new_invoice_email_path(@transaction), :class => 'email ajax', :title => 'Email', 'data-width' => 450
    end
  end

  def title
    if transaction.draft?
      "Proforma de #{type} #{transaction.ref_number}"
    else
      "Nota de #{type} #{transaction.ref_number}"
    end
  end

  def type
    if transaction.is_a?(Income)
      "venta"
    else
      "compra"
    end
  end

  def project
    if transaction.project_id.present?
      "Proyecto: #{h.link_to transaction.project, transaction.project}".html_safe
    end
  end

  def payment_date
    if transaction.payment_date.present?
      html = "<span class='n'> Vence el</span>"
      html << "<span id='due_on'> #{ h.lo transaction.payment_date }</span>"

      html.html_safe
    end
  end

  def approve_form
    h.render "transactions/approve_form" if transaction.draft?
  end

  def approve_deliver_form
    if transaction.is_a?(Income)
      h.render "transactions/approve_deliver" if can_approve_deliver?
    end
  end


  def description
    transaction.description unless transaction.description.blank?
  end

  def li_payments
    unless transaction.draft?
      h.content_tag(:li, "<a href=\"#payments\" id=\"tab_payments\">#{pay_method}</a>".html_safe)
    end
  end

  def payments_title
    if transaction.is_a?(Income)
      "Cobros"
    else
      "Pagos"
    end
  end

  def li_pay_plans
    if transaction.credit?
      h.content_tag(:li, "<a href='#pay_plans' id='tab_pay_plans'>Ver créditos</a>".html_safe)
    elsif not(transaction.draft?)
      h.content_tag(:li, "<a href='#pay_plans' id='tab_pay_plans'>Aprobar crédito</a>".html_safe)
    end
  end

  def li_inventory
    if transaction.deliver? or (transaction.is_a?(Buy) and not(transaction.draft?) )
      txt = @transaction.is_a?(Income) ? "Entrega" : "Recojo"
      h.content_tag(:li, "<a href='#inventory' id='tab_inventory'>#{txt}</a>".html_safe)
    end
  end

  def render_discount
    if transaction.is_a?(Income)
      h.render "transactions/discount", :transaction => transaction if transaction.discounted?
    end
  end

  def render_payments
    unless transaction.draft?
      h.render "/payments/payments", :transaction => transaction, :presenter => self
    end
  end

  def render_nulled_payments
    if transaction.account_ledgers.nulled.any?
      h.render "/payments/deleted", :transaction => transaction, :presenter => self
    end
  end

  def render_pay_plans
    return "" if transaction.paid?

    partial, url = false, ""

    case
    when transaction.credit?
      partial = "/pay_plans/pay_plans"
    when (not(transaction.credit?) and not(transaction.paid?) and not(transaction.draft?) )
      url = transaction.is_a?(Income) ? approve_credit_income_path(transaction) : approve_credit_buy_path(transaction)
      partial = "/pay_plans/approve"
    end

    h.render partial, :transaction => transaction, :presenter => self, :url => url if partial
  end

  def render_inventory
    case
    when ( transaction.is_a?(Income) and transaction.deliver? )
      render "/transactions/inventory", :transaction => transaction
    when ( transaction.is_a?(Buy) and not(transaction.draft?) )
      render "/transactions/inventory", :transaction => transaction
    end
  end

  def new_payment_link
    unless transaction.paid?
      tit = pay_method.singularize
      h.link_to("Nuevo #{tit}", 
        h.new_payment_path(:type => transaction.type.to_s, :id => transaction.id),
        :class => "new ajax button new_payment_link", :title => "Nuevo #{tit}",
        :id => 'new_payment_link',  'data-width' => "800", 'data-trigger' => 'payment')
    end
  end

  def pay_method
    if transaction.is_a?(Income)
      "Cobros"
    else
      "Pagos"
    end
  end

private
  def allow_action?
    transaction.draft? or h.session[:user][:rol] != "operations"
  end

  # Tells if the user can approve a transaction based on the preferences
  def can_approve_deliver?
    if not(transaction.draft?) and transaction.credit? and
      User::ROLES.slice(0,2).include?(h.session[:user][:rol]) and
      not(transaction.deliver?)

      true
    else
      false
    end
  end

end
