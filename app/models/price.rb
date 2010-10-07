# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Price < ActiveRecord::Base
  
  belongs_to :item

  class << self
    # creates an record from an Item
    def create_from_item(item)
      Price.create!(:item_id => item.id, :price => item.price, 
                    :discount => item.discount, :unitary_cost => item.unitary_cost)
    end
  end
end
