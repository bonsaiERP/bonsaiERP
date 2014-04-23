# Class to track history on movements
# test on spec/models/history_spec.rb
class Movements::History
  attr_reader :details_col, :histo, :movement

  delegate :state, :state_was, :state_changed?,
           :date, :date_was, :date_chaged?, :to_s,
           :due_date, :due_date_was, :due_date_changed?,
           to: :movement

  #delegate :history_data, to: :histo

  def initialize(details_col)
    @details_col = details_col.is_a?(Array) ? details_col.first : details_col
  end

  def set_history(movement, histo)
    @movement, @histo = movement, histo

    filter
    set_details
    set_state_col
    histo.operation_type = movement.operation_type
  end

  private

    def set_details
      all_details = movement.send(details_col).map do |det|
        get_detail(det)
      end

      histo.history_data["#{details_col}"] = detail_changes?(all_details)

      histo.all_data["#{details_col}"] = all_details
    end

    def get_detail(det)
      ha = det.attributes
      set_detail_changes(det, ha)
      ha.merge!('new_record?' => true) if det.new_record?
      ha.merge!('destroyed?' => true) if det.marked_for_destruction?

      ha
    end

    # Detect if there are changes except from the created_at updated_at
    def set_detail_changes(det, attrs)
      changes = det.changes.except('created_at', 'updated_at')

      if det.changed? && changes.any?
        changes.keys.each { |key| attrs["#{key}_was"] = det.send(:"#{key}_was") }
        attrs.merge!('changed?' => true)
      else
        attrs.merge!('changed?' => false)
      end
    end

    def detail_changes?(attr)
      attr.any? { |det| det['changed?'] || det['destroyed?'] || det['new_record?'] }
    end

    def filter
      histo.history_data['extras']['from'].each do |k, v|
        ext = history_data['extras']
        if v == ext['from'][k.to_s].to_s || v == ext['to'][k.to_sym].to_s
          history_data['extras']['from'].delete(k)
          history_data['extras']['to'].delete(k)
        end
      end
    rescue
      # no changes
    end

    #def set_details
    #  det_hash = get_details
    #  #histo.history_data.merge!(details_col => {from: [], to: det_hash, type: 'array'})  unless det_hash.empty?
    #  histo.history_data[details_col] = det_hash  unless det_hash.empty?
    #end

    #def get_details
    #  movement.send(details_col).each_with_index.map do |det, i|
    #    if det.new_record?
    #      { new_record: true, index: i }
    #    elsif changed_detail?(det)
    #      get_data(det).merge(id: det.id)
    #    elsif det.marked_for_destruction?
    #      { destroyed: true, index: i }.merge(det.attributes)
    #    else
    #      nil
    #    end
    #  end.compact
    #end

    def changed_detail?(det)
      det.changed_attributes.except('created_at', 'updated_at').any?
    end

    def set_state_col
      unless histo.history_data[:state].present?
        set_due_date_state(histo.history_data)  if due_date_changed?
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
