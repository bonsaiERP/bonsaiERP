# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Tag
  def self.included(base)
    base.instance_eval do
      before_save :set_valid_tags, if: :allowed_tag_ids?
      # Scopes for tags should be added
      scope :any_tags, -> (*t_ids) { where('tag_ids && ARRAY[?]', t_ids) }
      scope :all_tags, -> (*t_ids) { where('tag_ids @> ARRAY[?]', t_ids) }
    end
  end

  def select_cur(cur_id)
    account_currencies.select {|ac| ac.currency_id == cur_id }.first
  end

  private

    def allowed_tag_ids?
      tag_ids.is_a?(Array) && tag_ids.any?
    end

    def set_valid_tags
      t_ids = ::Tag.where(id: tag_ids).pluck(:id)

      self.tag_ids = t_ids & tag_ids
    end
end
