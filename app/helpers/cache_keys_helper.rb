module CacheKeysHelper
  def klass_default_key(klass)
    count = klass.count
    max_updated_at = klass.maximum(:updated_at).try(:utc).try(:to_s, :to_number)

    "#{tenant}-#{count}-#{max_updated_at}"
  end

  def today_key
    @today_key ||= Time.zone.now.to_date.to_s
  end

  def cache_key_for_tags
    @cache_key_for_tags ||= begin
      "tags-#{klass_default_key Tag}"
    end
  end
end
