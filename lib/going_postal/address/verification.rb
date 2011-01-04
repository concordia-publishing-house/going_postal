module GoingPostal
  class Address
    module Verification
      
      
      
      def suggest_valid_address
        @suggested_address ||= suggest_valid_address!
      end
      
      def suggest_valid_address!
        Rails.logger.info "[going_postal] verifying '#{self.to_s}'" if defined?(Rails)
        uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{Rack::Utils.escape(self.to_s)}&sensor=false")
        response = Net::HTTP.get_response(uri)
        json = ActiveSupport::JSON.decode(response.body)
        Address.new({
          :street => "#{read_part(json, 'street_number')} #{read_part(json, 'route')}",
          :city => read_part(json, 'locality'),
          :state => read_part(json, 'administrative_area_level_1', 'short_name'),
          :zip => read_part(json, 'postal_code')
        })
      end
      
      def read_part(json, part, variation='long_name')
        json['results'][0]['address_components'].find{|hash| hash['types'].include?(part)}[variation]
      end
      
      
      
      
      # # !nb: Jamin. Where did it come from?
      # def verify_address(address_info)
      #   raise "API key not specified.\nCall AddressStandardization::GoogleMaps.api_key = '...' before you call .standardize()." unless GoogleMaps.api_key
      # 
      #   address_info = address_info.stringify_keys
      # 
      #   address_str = [
      #     address_info["street"],
      #     address_info["city"],
      #     (address_info["state"] || address_info["province"]),
      #     address_info["zip"]
      #   ].compact.join(" ")
      #   url = "http://maps.google.com/maps/geo?q=#{address_str.url_escape}&output=xml&key=#{GoogleMaps.api_key}&oe=utf-8"
      #   AddressStandardization.debug "[GoogleMaps] Hitting URL: #{url}"
      #   uri = URI.parse(url)
      #   res = Net::HTTP.get_response(uri)
      #   return unless res.is_a?(Net::HTTPSuccess)
      #   
      #   content = res.body
      #   AddressStandardization.debug "[GoogleMaps] Response body:"
      #   AddressStandardization.debug "--------------------------------------------------"
      #   AddressStandardization.debug content
      #   AddressStandardization.debug "--------------------------------------------------"
      #   xml = Nokogiri::XML(content)
      #   xml.remove_namespaces! # good or bad? I say good.
      #   return unless xml.at("/kml/Response/Status/code").inner_text == "200"
      #   
      #   addr = {}
      #   
      #   addr[:street]   = get_inner_text(xml, '//ThoroughfareName').to_s
      #   addr[:city]     = get_inner_text(xml, '//LocalityName').to_s
      #   addr[:province] = addr[:state] = get_inner_text(xml, '//AdministrativeAreaName').to_s
      #   addr[:zip]      = addr[:postalcode] = get_inner_text(xml, '//PostalCodeNumber').to_s
      #   addr[:country]  = get_inner_text(xml, '//CountryName').to_s
      #   
      #   return if addr[:street] =~ /^\s*$/ or addr[:city]  =~ /^\s*$/
      #   
      #   Address.new(addr)
      # end
      # 
      # def   (xml, xpath)
      #   lambda {|x| x && x.inner_text.upcase }.call(xml.at(xpath))
      # end
      
      
    end
  end
end