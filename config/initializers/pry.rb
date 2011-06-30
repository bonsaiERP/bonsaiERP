begin  
  require 'pry'  
  module Rails  
    class Console  
      class IRB  
        def self.start  
          Pry.start  
        end  
      end   
    end  
  end  
rescue LoadError  
end  
