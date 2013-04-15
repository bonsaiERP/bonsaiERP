# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module UsersModulePresenter
  def creator_label
    return "<span class='label label-inverse' data-toggle='tooltip' title='#{creator} #{l created_at}'>#{user_icon}#{creator.id}</span>".html_safe if creator.present?
    ""
  end

  def approver_label
    return "<span class='label label-success' data-toggle='tooltip' title='#{approver} #{l approver_datetime}'>#{user_icon}#{approver.id}</span>".html_safe if approver.present?
    ""
  end

  def nuller_label
    return "<span class='label label-important' data-toggle='tooltip' title='#{nuller} #{l nuller_datetime}'>#{user_icon}#{nuller.id}</span>".html_safe if nuller.present?
    ""
  end

  def user_icon
    "<i class='icon-user'></i>"
  end
end
