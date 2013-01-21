#RSpec::Mocks::Methods.class_eval do
#  def stub_and_check(message_or_hash, opts={}, &block)
#    if Hash == message_or_hash
#      message_or_hash.each {|k,_| raise "#{self} doesn't respond to #{k}" unless respond_to?(k) }
#    else
#      raise "#{self} doesn't respond to #{message_or_hash}" unless respond_to?(message_or_hash)
#    end
#  end
#end
