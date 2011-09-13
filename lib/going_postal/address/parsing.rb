require 'going_postal/api/google'
require 'active_support/concern'


module GoingPostal
  class Address
    module Parsing
      extend ActiveSupport::Concern
      
      module ClassMethods
        
        def parse(string)
          Api::Google.find_address(string)
        end
        
        def parse!(string)
          Api::Google.find_address!(string)
        end
        
      end
    end
  end
end
