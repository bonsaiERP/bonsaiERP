# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::IncomeExpense
  def set_state_by_balance!
    if balance <= 0
      approve!
      self.state = 'paid'
    elsif balance < total
      approve!
      self.state = 'approved' if self.is_paid?
    else
      self.state = 'draft' if state.blank?
    end
  end

  def discount
    gross_total - total
  end

  def discount_percent
    discount/gross_total
  end

  def approve!
    if is_draft?
      self.state = 'approved'
      self.approver_id = UserSession.id
      self.approver_datetime = Time.zone.now
      self.due_date = Date.today
    end
  end

  def null!
    if can_null?
      update_attributes(state: 'nulled', nuller_id: UserSession.id, nuller_datetime: Time.zone.now)
    end
  end

  def can_null?
    total === amount && !is_nulled?
  end
end
