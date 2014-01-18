# encoding: utf-8
module Models::Updater
  def self.included(base)
    base.instance_eval do
      before_save :set_updater

      belongs_to :updater, class_name: 'User'
    end
  end

  private

    def set_updater
      self.updater_id = UserSession.id
    end
end
