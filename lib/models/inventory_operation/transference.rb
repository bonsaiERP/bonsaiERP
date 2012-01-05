# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::InventoryOperation
  class Transference
    attr_accessor :store_out, :store_in
    attr_reader :inventory_operation_out, :inventory_operation_in
    # Recives two store models to make the transference, one is the sender and the othre the reciever
    def initialize(store_out)
      @store_out = store_out
      @inventory_operation_out = InventoryOperation.new(:store_id => @store_out, :operation => 'transout')
    end

    # Saves the transference
    # @param params # Attributes for transference
    def save(params)

    end
  end
end
