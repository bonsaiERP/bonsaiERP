# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module UserLogHelper
  def creator_label
    return user_icon(class: 'text', title: "CREADO: #{user_label_text creator, created_at}") if creator.present?
    ""
  end

  def approver_label
    return user_icon(class: 'text-success', title: "APROBADO: #{user_label_text approver, approver_datetime}") if approver.present?
    ""
  end

  def nuller_label
    return user_icon(class: 'text-error', title: "ANULADO: #{user_label_text nuller, nuller_datetime}") if nuller.present?
    ""
  end

  def user_icon(attrs)
    "<i class='icon-user #{attrs.fetch(:class)}' title='#{attrs.fetch(:title)}' data-toggle='tooltip'></i>".html_safe
  end

  def user_label_text(u, t)
    "#{u} #{l t}, ID: #{u.id}"
  end
end
