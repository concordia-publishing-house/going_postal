require 'going_postal/api/google'
require 'going_postal/api/usps'


module GoingPostal
  class Address
    module Verification
      
      
      
      @api = :google
      mattr_accessor :api
      
      
      
      def matches_authorized_version?
        (self == suggest_valid_address)
      end
      
      # Lazy verification
      def suggest_valid_address
        @suggested_address ||= suggest_valid_address!
      end
      alias :suggested :suggest_valid_address
      
      def suggest_valid_address!
        Rails.logger.info "[going_postal] verifying '#{self.to_s}'" if defined?(Rails)
        api.find_address(self) || Address.empty
      end
      
      
      
    private
      
      
      
      def api
        case ::GoingPostal::Address::Verification.api
        when :usps; Api::Usps
        else        Api::Google
        end
      end
      
      
      
    end
  end
end