class Attachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  belongs_to :user

  dragonfly_accessor :attachment do
    copy_to(:small_attachment) { |a| a.thumb('200x200')   if a.image? }
    copy_to(:medium_attachment) { |a| a.thumb('500x500')  if a.image? }
  end
  dragonfly_accessor :small_attachment
  dragonfly_accessor :medium_attachment

  validates :attachment, presence: true
  validates :attachable, presence: true, :if => :has_attachable?
  validates :position, presence: true, numericality: true

  def save_attachment
    self.name = attachment.name
    self.size = attachment.size
    self.image = attachment.image?
    self.user_id = UserSession.id

    set_image_attributes  if image?

    self.save
  end

  def extname
    File.extname name
  end

  def small_attachment_uid
    image_attributes['small_attachment_uid']
  rescue
    nil
  end

  def medium_attachment_uid
    image_attributes['medium_attachment_uid']
  rescue
    nil
  end

  # Delegated methods for json response
  delegate :url, :remote_url, to: :attachment, prefix: true, allow_nil: true
  delegate :url, :remote_url, to: :small_attachment, prefix: true, allow_nil: true
  delegate :url, :remote_url, to: :medium_attachment, prefix: true, allow_nil: true

  def as_json(options = {})
    super({
      only: [:id, :name, :image, :size, :position, :attachment_uid, :created_at, :updated_at, :attachable_type, :attachable_id],
      methods: [
        :attachment_url, :attachment_remote_url,
        :small_attachment_url, :medium_attachment_url
      ]
      }.merge(options)
    )
  end

  def to_api
    as_json(only: Attachment.column_names, methods: [])
  end

  def move_up(pos)
    res = true
    return true if pos > position
    return true  if other_attachables_less_than_equal(position).empty?

    self.class.transaction do
      self.position = position - 1

      res = other_attachables_less_than_equal(position)
        .update_all("position = position + 1") && self.save

      raise ActiveRecord::Rollback  unless res
    end

    res
  end

  def move_down(pos)
    res = true
    return true if pos < position
    return true  if other_attachables_greater_than_equal(position).empty?

    self.class.transaction do
      self.position = position + 1

      res = other_attachables_greater_than_equal(position).update_all("position = position - 1")
      res = res && self.save

      raise ActiveRecord::Rollback  unless res
    end

    res
  end

  private

    def other_attachables
      @attachables ||= Attachment.where(attachable_id: attachable_id, attachable_type: attachable_type).where.not(id: id)
    end

    def other_attachables_less_than_equal(pos)
      other_attachables.where("attachments.position <= ?", pos)
    end

    def other_attachables_greater_than_equal(pos)
      other_attachables.where("attachments.position >= ?", pos)
    end

    def small_attachment_uid=(val)
      self.image_attributes ||= {}
      self.image_attributes['small_attachment_uid'] = val
    end

    def medium_attachment_uid=(val)
      self.image_attributes ||= {}
      self.image_attributes['medium_attachment_uid'] = val
    end

    def set_image_extras
      create_thumbs
      set_image_attributes
    end

    def has_attachable?
      attachable_type.present? && attachable_id.present?
    end

    def set_image_attributes
      self.image_attributes ||= {}
      self.image_attributes[:format] = attachment.format
      self.image_attributes[:width] = attachment.width
      self.image_attributes[:height] = attachment.height
    end
end
