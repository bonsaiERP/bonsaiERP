class History < ActiveRecord::Base

  # Relationships
  belongs_to :historiable, polymorphic: true
  belongs_to :user

  store_accessor :extras, :klass_to_s, :operation_type

  def history_attributes
    @history_attributes ||= history_data.keys
  end

  def history
    @hist_data ||= get_typecasted
  end

  private

    def get_typecasted
      Hash[history_data.map do |key, val|
        [key, typecast_hash(val) ]
      end]
    end

    def typecast_hash(val)
      case val['type']
      when 'string', 'text', 'integer', 'boolean', 'float'
        { from: val['from'], to: val['to'], type: val['type'] }
      when 'date', 'datetime', 'time'
        { from: typecast_transform(val['from'], val['type']),
          to: typecast_transform(val['to'], val['type']), type: val['type'] }
      when 'decimal'
        { from: BigDecimal.new(val['from'].to_s),
          to: BigDecimal.new(val['to'].to_s), type: val['type'] }
      end
    rescue
      {}
    end

    def typecast_transform(val, type)
      val.to_s.send(:"to_#{type}")
    rescue
      val
    end

end
