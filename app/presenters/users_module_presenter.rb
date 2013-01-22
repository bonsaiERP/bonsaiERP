module UsersModulePresenter
  def creator_label
    return "<span class='label label-inverse' rel='tooltip' title='#{creator} #{l created_at}'>C-#{creator.id}</span>".html_safe if creator.present?
    ""
  end

  def approver_label
    return "<span class='label label-success' rel='tooltip' title='#{approver} #{l approver_datetime}'>AP-#{approver.id}</span>".html_safe if approver.present?
    ""
  end

  def nuller_label
    return "<span class='label' rel='tooltip' title='#{nuller} #{l nuller_datetime}'>AN-#{nuller.id}}</span>".html_safe if nuller.present?
    ""
  end
end
