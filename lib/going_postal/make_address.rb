module GoingPostal
  module MakeAddress
    
    
    attr_accessor :geocoding_enabled
    
    
    def make_address(*parts)
      @geocoding_enabled = true
      
      options = parts.extract_options!
      geocode = options[:geocode]
      
      parts.each do |part_id|
        if geocode
          class_eval <<-RUBY
            def #{part_id}
              attributes = super
              attributes = YAML::load(attributes) if attributes.is_a?(String)
              return GoingPostal::Address.new if attributes.nil?
              
              GoingPostal::Address.new(attributes.merge(latitude: #{part_id}_latitude, longitude: #{part_id}_longitude)) # <-- difference: uses lat/long attrs
            end
            
            def #{part_id}=(address)
              address = GoingPostal::Address.new(address) if address.is_a?(Hash)
              super(address.blank? ? nil : address.to_yaml)
              
              unless address.blank? # <-- difference: attempts to geocode
                address.geocode if self.class.geocoding_enabled
                self.#{part_id}_latitude = address.latitude
                self.#{part_id}_longitude = address.longitude
              end
            end
          RUBY
        else
          class_eval <<-RUBY
            def #{part_id}
              attributes = super
              attributes = YAML::load(attributes) if attributes.is_a?(String)
              return GoingPostal::Address.new if attributes.nil?
              
              GoingPostal::Address.new(attributes)
            end
            
            def #{part_id}=(address)
              address = GoingPostal::Address.new(address) if address.is_a?(Hash)
              super(address.blank? ? nil : address.to_yaml)
            end
          RUBY
        end
      end
    end
    
    
  end
end
