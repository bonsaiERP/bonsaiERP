# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ContactPresenter < BasePresenter
  def address_tag
    "#{ icon 'icon-building muted', 'Dirección' } #{sanitize address}".html_safe if address.present?
  end

  def phone_tag
    "#{ icon 'icon-phone muted', 'Teléfono' } #{sanitize phone}".html_safe if phone.present?
  end

  def email_tag
    "#{ icon 'icon-envelope muted', 'Email' } #{sanitize email}".html_safe if email.present?
  end

  def tax_number_tag
    "#{ icon 'icon-barcode muted', 'Código tributario' } #{sanitize tax_number}".html_safe if tax_number.present?
  end

  def mobile_tag
    "#{ icon 'icon-mobile muted', 'Móvil' } #{sanitize mobile}".html_safe if mobile.present?
  end

  def tot_in_tag
    if tot_in.to_f > 0
      "#{text_green icon('icon-plus', 'Por cobrar')} #{ntc tot_in} #{template.currency_label}".html_safe
    end
  end

  def tot_out_tag
    "#{text_red icon('icon-minus', 'Por pagar')} #{ntc tot_out} #{template.currency_label}".html_safe  if tot_out.to_f > 0
  end

  def operations
    @operations ||= operations_filter.includes(:creator, :approver, :nuller, :updater, :tax)
    .order('date desc, id desc').page(page)
  end

  def operations_filter
    case context.params[:operation]
    when 'all' then to_model.accounts.operations
    when 'income' then to_model.accounts.where(type: 'Income')
    when 'expense' then to_model.accounts.where(type: 'Expense')
    when 'loangive' then to_model.accounts.where(type: 'Loans::Give')
    when 'loanreceive' then to_model.accounts.where(type: 'Loans::Receive')
    end
  end

  def page
    p = context.params[:page].to_i
    p > 0 ? p : 1
  end

  def operation_partial(operation)
    case operation.class.to_s
    when 'Income'
      context.render partial: 'contacts/income', locals: { income: present(operation) }
    when 'Expense'
      context.render partial: 'contacts/expense', locals: { expense: present(operation) }
    when 'Loans::Give', 'Loans::Receive'
      context.render partial: 'contacts/loan', locals: { loan: present(operation) }
    end
  end
end
