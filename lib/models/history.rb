module Models::History

  def self.included(base)
    base.send(:extend, InstanceMethods)
    base.instance_eval do
      before_save :create_history
      has_many :histories, -> { order('histories.created_at desc, id desc') }, as: :historiable, dependent: :destroy
      delegate :history_klass, to: self

      def history_klass
        @history_klass ||= NullHistoryClass.new
      end
    end

  end

  module InstanceMethods
    def has_movement_history(details_col)
      @history_klass = Movements::History.new(details_col)
    end
  end

  private

    def create_history
      if new_record?
        h = store_new_record
      else
        h = store_update
      end
      h.klass_type = self.class.to_s

      h.save
    end

    def store_new_record
      histories.build(new_item: true, user_id: history_user_id,
                      historiable_type: self.class.to_s, history_data: {})
    end

    def store_update
      h = get_data
      history_klass.set_history(self, h)

      histories.build(new_item: false, history_data: h, historiable_type: self.class.to_s,
                      user_id: history_user_id)
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

    # Null object
    class NullHistoryClass
      def set_history(klass, h); end
    end
end
