class Item < ActiveRecord::Base
  acts_as_org

  belongs_to :unit

  belongs_to :itemable, :polymorphic => true
end
