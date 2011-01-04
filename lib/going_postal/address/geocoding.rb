require 'net/http'
require 'rack'


module GoingPostal
  class Address
    module Geocoding
      
      
      
      attr_reader :latitude, :longitude
      
      
      
      # Lazy geocoding
      def geocode
        geocode! if latitude.nil? or longitude.nil?
      end
      
      
      
      # c.f. http://blog.nicolasblanco.fr/2010/09/29/quick-and-simple-geocoding/
      def geocode!
        Rails.logger.info "[going_postal] geocoding '#{self.to_s}'" if defined?(Rails)
        uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{Rack::Utils.escape(self.to_s)}&sensor=false")
        response = Net::HTTP.get_response(uri)
        json = ActiveSupport::JSON.decode(response.body)
        @latitude = json['results'][0]['geometry']['location']['lat']
        @longitude = json['results'][0]['geometry']['location']['lng']
      end
      
      
      
    end
  end
end
