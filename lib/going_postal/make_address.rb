module GoingPostal
  module MakeAddress
    
    
    def make_address(*parts)
      options = parts.extract_options!
      
      parts.each do |part_id|
        latitude_column = "#{part_id}_latitude"
        longitude_column = "#{part_id}_longitude"
        has_latlong = column_names.member?(latitude_column) and column_names.member?(longitude_column)
        geocode = has_latlong && options[:geocode]
        
        class_eval <<-RUBY
          def #{part_id}
            attributes = super
            attributes = YAML::load(attributes) if attributes.is_a?(String)
            return GoingPostal::Address.new if attributes.nil?
            
            attributes = attributes.merge(latitude: #{latitude_column}, longitude: #{longitude_column}) if #{has_latlong}
            GoingPostal::Address.new(attributes)
          end
          
          def #{part_id}=(address)
            address = GoingPostal::Address.new(address) if address.is_a?(Hash)
            super(address.blank? ? nil : address.to_yaml)
            
            if #{has_latlong} && !address.blank?
              address.geocode if #{geocode}
              self.#{latitude_column} = address.latitude
              self.#{longitude_column} = address.longitude
            end
          end
        RUBY
      end
    end
    
    
  end
end
