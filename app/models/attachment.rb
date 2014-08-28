class Attachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  dragonfly_accessor :attachment

  validates :attachment, presence: true

  def save_attachment
    self.save
  end
end
