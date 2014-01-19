class History < ActiveRecord::Base

  # Relationships
  belongs_to :historiable, polymorphic: true
  belongs_to :user

  serialize :history_data, JSON

  def history_attributes
    @history_attributes ||= history_data.keys.map(&:to_sym)
  end
end
