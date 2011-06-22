# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module HashExt
  # Transforns for date parameters
  def transform_date_parameters!(*keys)
    keys.each do |key|
      self[key] = ""
      self[key] = get_date_val(key)
      unless self[key].blank?
        time = get_time_val(key)
        self[key] << " #{time}" unless time.blank?
      else
        self[key] << get_time_val(key)
      end
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

