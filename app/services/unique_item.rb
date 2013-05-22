# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# Checks for unique item_ids and adds an error to the found details
class UniqueItem < Struct.new(:klass)
  delegate :details, to: :klass

  def valid?
    res = true
    details.each do |det|
      add_to_hash(det.item_id)

      if repeated_item?(det.item_id)
        res = false 
        det.errors.add(:item_id, I18n.t("errors.messages.item.repeated"))
      end
    end

    klass.errors.add(:base, I18n.t("errors.messages.item.repeated_items")) unless res

    res
  end

private
  def add_to_hash(item_id)
    @h ||= Hash.new(0)
    @h[item_id] += 1
  end

  def repeated_item?(item_id)
    @h[item_id] > 1
  end
end
