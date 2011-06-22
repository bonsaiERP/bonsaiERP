# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module HashExt
  # Transforns for date parameters
  def transform_date_parameters!(*keys)
    keys.each do |key|
      t = get_date_val(key)
      unless t.blank?
        time = get_time_val(key)
        t << " #{time}" unless time.blank?
      else
        t << get_time_val(key)
      end
      self[key] = t unless t.blank?
    end
    self
  end

  def transform_time_and_symbolize!(*keys)
    transform_date_parameters!(*keys).symbolize_keys!
  end

  def get_date_val(key)
    (1..3).map {|v| "#{key}(#{v}i)"}.inject([]) do |arr,v|
      arr << self.delete(v) if self[v].present?
      arr
    end.join("-")
  end

  def get_time_val(key)
    (4..6).map {|v| "#{key}(#{v}i)"}.inject([]) do |arr,v|
      arr << self.delete(v) if self[v].present?
      arr
    end.join(":")
  end

end

