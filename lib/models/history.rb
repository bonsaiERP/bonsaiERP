module Models::History
  def self.included(base)
    base.instance_eval do
      before_save :create_history
      has_many :histories, -> { order('histories.created_at desc, id desc') }, as: :historiable, dependent: :destroy
    end
  end

  private

    def create_history
      if new_record?
        store_new_record
      else
        store_update
      end
    end

    def store_new_record
      h = histories.build(new_item: true, user_id: history_user_id, history_data: {})
      h.save
    end

    def store_update
      h = histories.build(new_item: false, history_data: get_data, user_id: history_user_id)
      h.save
    end

    def get_data
      Hash[ changed_attributes.map { |k, v|
        [k, { from: v, to: send(k), type: v.class.to_s} ]
      }]
    end

    def history_user_id
      UserSession.id
    end
end
