module Models::History

  def self.included(base)
    base.instance_eval do
      before_save :create_history
      has_many :histories, -> { order('histories.created_at desc, id desc') }, as: :historiable, dependent: :destroy
    end

    base.send(:extend, InstanceMethods)
  end

  module InstanceMethods
    def history_with_details(attr)
      @history_details = attr
    end

    def history_details
      @history_details
    end
  end

  private

    def create_history
      if new_record?
        h = store_new_record
      else
        h = store_update
      end

      h.save
    end

    def store_new_record
      histories.build(new_item: true, user_id: history_user_id, history_data: {})
    end

    def store_update
      if details_col.present?
        histories.build(new_item: false, history_data: get_data_with_details, user_id: history_user_id)
      else
        histories.build(new_item: false, history_data: get_data, user_id: history_user_id)
      end
    end

    def get_data_with_details
      hash = get_data
      hash[details_col] = get_data_details
      hash.delete(details_col)  if hash[details_col].empty?

      hash
    end

    def get_data_details
      send(details_col).each_with_index.map do |det, i|
        case
        when det.new_record?
          { new_record: true, index: i }
        when changed_detail?(det)
          get_data(det).merge(id: det.id)
        else
          nil
        end
      end.compact
    end

    def get_data(object = self)
      Hash[ get_object_attributes(object).map { |k, v|
        [k, { from: v, to: object.send(k), type: object.class.column_types[k].type } ]
      }]
    end

    def history_user_id
      UserSession.id
    end

    def get_object_attributes(object)
      object.changed_attributes.except('created_at', 'updated_at')
    end

    def changed_detail?(det)
      det.changed_attributes.except('created_at', 'updated_at').any?
    end

    def details_col
      self.class.history_details
    end
end
