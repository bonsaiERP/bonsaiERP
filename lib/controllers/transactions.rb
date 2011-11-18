module Controllers::Transactions

  protected
  def update_all_deliver
    if Transaction.for_deliver.any?
      Transaction.for_deliver.each do |trans|
        trans.deliver = true
        trans.save(:validate => false)
      end
    end
  end

end
