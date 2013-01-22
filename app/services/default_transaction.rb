# encoding: utf-8
class DefaultTransaction < BaseService
  attr_reader :transaction

private
  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end

  def approve_transaction
    transaction.state = 'approved'
    transaction.payment_date = transaction.date
    transaction.approver_id = UserSession.id
    transaction.approver_datetime = Time.zone.now
  end
end
