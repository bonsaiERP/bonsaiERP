# Class to track history on movements
# test on spec/models/history_spec.rb
class Movements::History
  attr_reader :details_col, :hist, :movement

  delegate :state, :state_was, :state_changed?,
           :date, :date_was, :date_chaged?, :to_s,
           :due_date, :due_date_was, :due_date_changed?,
           to: :movement

  delegate :history_data, to: :hist

  def initialize(details_col)
    @details_col = details_col
  end

  def set_history(movement, hist)
    @movement, @hist = movement, hist

    set_details
    set_state_col
    history_data[:operation_type] = movement.operation_type
  end

  private

    def set_details
      det_hash = get_details
      history_data[details_col] = det_hash  unless det_hash.empty?
    end

    def get_details
      movement.send(details_col).each_with_index.map do |det, i|
        if det.new_record?
          { new_record: true, index: i }
        elsif changed_detail?(det)
          get_data(det).merge(id: det.id)
        elsif det.marked_for_destruction?
          { destroyed: true, index: i }.merge(det.attributes)
        else
          nil
        end
      end.compact
    end

    def changed_detail?(det)
      det.changed_attributes.except('created_at', 'updated_at').any?
    end

    def set_state_col
      unless history_data[:state].present?
        set_due_date_state(history_data)  if due_date_changed?
      end
    end

    def set_due_date_state(h)
      if due_date_was.is_a?(Date)
        if today > due_date_was
          h[:state] = { from: 'due', to: state, type: 'string' }
        elsif today > due_date
          h[:state] = { from: state, to: 'due', type: 'string' }
        end
      end
    end

    def get_data(object = movement)
      Hash[ get_object_attributes(object).map { |k, v|
        [k, { from: v, to: object.send(k), type: object.class.column_types[k].type } ]
      }]
    end

    def get_object_attributes(object)
      object.changed_attributes.except('created_at', 'updated_at')
    end

    def today
      today ||= Date.today
    end
end
