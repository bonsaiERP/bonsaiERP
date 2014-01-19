class History < ActiveRecord::Base

  # Relationships
  belongs_to :historiable, polymorphic: true
  belongs_to :user

  serialize :history_data, JSON

  def history_attributes
    @history_attributes ||= history_data.keys.map(&:to_sym)
  end

  def history_data
    @hist_data ||= get_typecasted read_attribute(:history_data)
  end

  private

    def get_typecasted(hash)
      Hash[hash.map do |k, v|
        [k.to_sym, typecast_hash(v) ]
      end]
    end

    def typecast_hash(v)
      case v['type']
      when 'String', 'Integer', 'TrueClass', 'FalseClass', 'Float'
        { from: v['from'], to: v['to'] }
      else
        klass = v['type'].safe_constantize
        { from: klass.new(v['from']), to: klass.new(v['to']) }
      end
    end
end
