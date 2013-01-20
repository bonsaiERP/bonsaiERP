# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountLedgerPresenter < Resubject::Presenter
  def conciliated
    if conciliation?
      "<i class='icon-ok text-success' title='Verficado' rel='tooltip'></i>"
    else
      "<i class='icon-cross text-error' title='No verficado' rel='tooltip'></i>"
    end
  end

  def creator_label
    return "<span class='label label-inverse' rel='tooltip' title='#{creator}'>U-#{creator.id}</span>" if creator.present?
    ""
  end

  def approver_label
    return "<span class='label label-success' rel='tooltip' title='#{approver}'>U-#{approver.id}</span>" if approver.present?
    ""
  end

  def nuller_label
    return "<span class='label' rel='tooltip' title='#{nuller}'>U-#{nuller.id}}</span>" if nuller.present?
    ""
  end


  def initials(name)
    name.split(' ').map(&:first).join('')
  end
end
