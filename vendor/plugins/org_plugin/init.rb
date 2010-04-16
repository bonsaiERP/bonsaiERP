# Include hook code here
require 'acts_as_org'
ActiveRecord::Base.send(:include, Err::Acts::Org)
