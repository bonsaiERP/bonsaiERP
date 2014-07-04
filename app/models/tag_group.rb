class TagGroup < ActiveRecord::Base

  validates :name, presence: true, length: { within: 3..100 }

  def tags(reload = false)
    @tags = nil  if reload
    @tags ||= Tag.where(id: tag_ids)
  end

  def tag_ids=(ids)
    @tags = nil
    write_attribute(:tag_ids, Array(ids))
  end

  def to_s
    name
  end
end
