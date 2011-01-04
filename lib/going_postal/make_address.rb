module GoingPostal
  module MakeAddress
    
    
    
    attr_accessor :geocoding_enabled
    
    
    
    # cf http://earthcode.com/blog/2006/12/latitude_and_longitude_columns.html
    def make_address(*parts)
      @geocoding_enabled = true
      
      options = parts.extract_options!
      geocode = options[:geocode]
      
      parts.each do |part_id|
        mapping = [part_id, :to_yaml]
        mapping = [mapping, ["#{part_id}_latitude".to_sym, :latitude], ["#{part_id}_longitude".to_sym, :longitude]] if geocode
        Rails.logger.info "[going_postal] mapping: #{mapping.inspect}"
        composed_of part_id,
          :class_name => "GoingPostal::Address",
          :allow_nil => true,
          :mapping => mapping,
          :constructor => Proc.new {|address_yaml, lat, long|
            case address_yaml
            when Address;       return address_yaml
            when String, IO;    address_yaml = YAML::load(address_yaml)
            end
            if address_yaml.is_a?(Hash)
              Address.new(address_yaml.merge(:latitude => lat, :longitude => long))
            else
              Rails.logger.info("[going_postal] can't make address from #{address_yaml.class}") if defined?(Rails)
              Address.new
            end
          },
          :converter => Proc.new {|value|
            value.is_a?(Hash) ? Address.new(value) : value
          }
        
        if geocode
          send :alias_method, "composed_of_#{part_id}=".to_sym, "#{part_id}=".to_sym
          send :define_method, "#{part_id}=" do |address|
            address.geocode if self.class.geocoding_enabled
            send("composed_of_#{part_id}=", address)
          end
        end
      end
    end
    
    
    
  end
end