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

  def history_data_raw
    read_attribute(:history_data)
  end

  private

    def get_typecasted(hash)
      Hash[hash.map do |k, v|
        [k.to_sym, typecast_hash(v) ]
      end]
    end

    def typecast_hash(v)
      return typecast_array(v)  if v.is_a?(Array)

      case v['type']
      when 'string', 'integer', 'boolean', 'float'
        { from: v['from'], to: v['to'], type: v['type'] }
      when 'date', 'datetime', 'time'
        { from: typecast_transform(v['from'], v['type']),
          to: typecast_transform(v['to'], v['type']), type: v['type'] }
      when 'decimal'
        { from: BigDecimal.new(v['from'].to_s),
          to: BigDecimal.new(v['to'].to_s), type: v['type'] }
      end
    end

    def typecast_transform(val, type)
      val.to_s.send(:"to_#{type}")
    rescue
      val
    end

    def typecast_array(arr)
      arr.map do |v|
        _id = v.delete('id')
        case
        when v['new_record']
          { index: v['index'] , new_record: true }
        when v['destroyed']
          v.symbolize_keys
        else
          get_typecasted(v).merge(id: _id)
        end
      end
    end

end
