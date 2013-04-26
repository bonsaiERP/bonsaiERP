# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module UsersModulePresenter
  def creator_label
    return user_icon(class: 'text', title: "ID: #{creator.id}, #{creator} #{l created_at}'") if creator.present?
    ""
  end

  def approver_label
    return user_icon(class: 'text-success', title: "ID: #{approver.id}, #{approver} #{l approver_datetime}") if approver.present?
    ""
  end

  def nuller_label
    return user_icon(class: 'text-error', title: "ID: #{nuller.id}, #{nuller} #{l nuller_datetime}'") if nuller.present?
    ""
  end

  def user_icon(attrs)
    "<i class='icon-user #{attrs.fetch(:class)}' title='#{attrs.fetch(:title)}' data-toggle='tooltip'></i>".html_safe
  end
end
