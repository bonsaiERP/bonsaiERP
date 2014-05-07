# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module UserLogModule
  def creator_label
    return user_icon(class: 'text creator', title: "CREADO: #{user_label_text creator, created_at}") if creator.present?
    ''
  end

  def approver_label
    return user_icon(class: 'bonsai-dark approver', title: "APROBADO: #{user_label_text approver, approver_datetime}") if approver.present?
    ""
  end

  def nuller_label
    return user_icon(class: 'red2 nuller', title: "ANULADO: #{user_label_text nuller, nuller_datetime}") if nuller.present?
    ""
  end

  def updater_label
    user_icon(class: 'blue updater', title: "MODIFICADO por: #{user_label_text updater, updated_at}") if updater.present?
  end

  def user_icon(attrs)
    "<i class='icon-user #{attrs.fetch(:class)}' title='#{attrs.fetch(:title)}' data-toggle='tooltip'></i>".html_safe
  end

  def user_label_text(u, t)
    "#{u} #{context.lo t}, ID: #{u.id}"
  end

  def user_log_list
    [:creator, :approver, :nuller, :updater]
  end
end
