# encoding: utf-8
module Tags::TagModule
  def self.included(base)
    base.instance_eval do
      before_save :set_valid_tags
      # Scopes for tags should be added
      scope :any_tags, -> (*t_ids) { where('tag_ids && ARRAY[?]', t_ids) }
      scope :all_tags, -> (*t_ids) { where('tag_ids @> ARRAY[?]', t_ids) }
    end
  end

  def select_cur(cur_id)
    account_currencies.select {|ac| ac.currency_id == cur_id }.first
  end

  def tag_ids
    @tag_ids ||= Array(read_attribute(:tag_ids).gsub(/[{|}]/, '').split(",").map(&:to_i))
  end

  def tag_ids=(ary = nil)
    arr = Array(ary).map(&:to_i)
    write_attribute(:tag_ids, "{#{ arr.join(',') }}")
    @tag_ids = arr
  end

private
  def set_valid_tags
    t_ids = Tag.where(id: tag_ids).pluck(:id)

    self.tag_ids = tag_ids.select {|v| t_ids.include?(v) }
  end
end
