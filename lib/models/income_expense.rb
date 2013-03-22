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

end
