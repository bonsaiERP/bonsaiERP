class MovementHistoryDetailsPresenter < BasePresenter
  delegate :currency, :creator, to: :historiable

  #alias_method :movement, :historiable

  def details_col
    @details_col ||= historiable.is_a?(Income) ? 'income_details' : 'expense_details'
  end

  def details
    @details ||= all_data[details_col]
      .map { |det| MovementHistoryItem.new(det, items_hash, self) }
  rescue
    []
  end

  def items_hash
    @items_hash ||= begin
      Hash[Item.where(id: item_ids).map { |item| [item.id, item] }]
    end
  end

  def item_ids
    @item_ids ||= all_data[details_col]
      .map { |det| [det['item_id'], det['item_id_was'] ] }.flatten.compact
  end

  # Class to present details
  class MovementHistoryItem
    attr_reader :items_hash, :details, :presenter

    delegate :code, :context, to: :presenter
    delegate :ntc, to: :context

    def initialize(details, items_hash, presenter)
      @details, @items_hash, @presenter = details, items_hash, presenter
    end

    def item
      items_hash[item_id]
    end

    def item_was
      items_hash[item_id_was]
    end

    [:price, :quantity, :balance].each do |meth|
      define_method meth do
        BigDecimal.new(details[meth.to_s])
      end

      define_method :"#{meth}_was" do
        begin
          BigDecimal.new(details["#{meth}_was"])
        rescue
          nil
        end
      end
    end

    [:item_id].each do |meth|
      define_method meth do
        details[meth.to_s]
      end

      define_method :"#{meth}_was" do
        details["#{meth}_was"]
      end
    end

    def subtotal
      price * quantity
    end

    def subtotal_was
      price_was * quantity_was
    end

    # Present if the item changed
    def changed(field)
      case field
      when 'item'
        return send(field)  unless changed?(field)

        "de #{code details["#{field}_was"]} a #{ code details[field]}".html_safe
      when 'price', 'quantity', 'balance'
        return ntc send(field)  unless changed?(field)

        "de #{code ntc(send(:"#{field}_was"))} a #{ code ntc(send(field))}".html_safe
      when 'subtotal'
        return ntc(subtotal)  unless subtotal_changed?
        "de #{code ntc(subtotal_was)} a #{ code ntc(subtotal)}".html_safe
      end
    end

    def changed?(field)
      !new_record? && !destroyed? && details["#{field}_was"].present?
    end

    def line_change_css
      return 'line-new' if new_record?
      return 'line-deleted' if destroyed?
    end

    def new_record?
      !!details['new_record?']
    end

    def destroyed?
      !!details['destroyed?']
    end

    def changed_css(field)
      details["#{field}_was"].present? ? 'red' : ''
    end

    def subtotal_was
      if subtotal_changed?
        [price, price_was].compact.last * [quantity, quantity_was].compact.last
      end
    end

    def subtotal
      price * quantity
    end

    def subtotal_changed?
      (details['price_was'].present? || details['quantity_was'].present?) && !(new_record?)
    end
  end

end

