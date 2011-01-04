require 'going_postal/api/google'
require 'going_postal/api/usps'


module GoingPostal
  class Address
    module Verification
      
      
      
      @api = :google
      mattr_accessor :api
      
      
      
      # Lazy verification
      def suggest_valid_address
        @suggested_address ||= suggest_valid_address!
      end
      
      def suggest_valid_address!
        Rails.logger.info "[going_postal] verifying '#{self.to_s}'" if defined?(Rails)
        response = api.find_address(self).first
        if response
          Address.new({
            :street => "#{response.get_address_component(:street_number)} #{response.get_address_component(:route)}",
            :city => response.get_address_component(:locality),
            :state => response.get_address_component(:administrative_area_level_1, :short),
            :zip => response.get_address_component(:postal_code)
          })
        else
          Address.empty
        end
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