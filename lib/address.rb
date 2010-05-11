require 'composite/base'

class Address < Composite::Base
  include HashAccessors
  hash_accessors_for :hash, [:street, :city, :state, :zip]

  def initialize(hash=nil)
    super()
    @hash = hash.is_a?(Hash) ? symbolize_keys(hash) : {}
  end
  
  # Convert all of the keys in the hash to symbols. This is taken from Rails hash extensions.
  # It is necessary to create all addresses the same as searches against the address is a text
  # search with the YAML from an address.
  def symbolize_keys(hash)
    return hash if not hash
    new_hash = {}
    hash.each do |k,v|
      new_hash[k.to_sym] = v
    end
    new_hash
  end
  
  def to_s
    if (street and (street.length>0))
      "#{street}\r\n#{city}, #{state} #{zip}"
    end
  end
  
  def to_html
    # todo 'h' is not recognized; but add html cleaning here
    html = "#{street}"
    html << "<br/>" if(street and (street.length>0))
    html << "#{city}, #{state} #{zip}" if(city and (city.length>0))
    html
  end
  
  def self.loader(address_as_string)
    if address_as_string
      Address.new YAML::load(address_as_string)
    else
      Address.new
    end
  end
  
  def self.converter(value)
    return Address.new(value) if value.is_a? Hash
    return nil
  end
  
  def to_yaml
    # calling to_hash first will make sure the hash is a Hash and not HashWithIndifferentAccess
    symbolize_keys(@hash).to_hash.to_yaml
  end
  
  def blank?
    (street.blank? and city.blank? and state.blank? and zip.blank?)
  end

  def exists?
    !blank?
  end

  STATES = [
#    [ "Select a State", "" ],
    [ "Alabama", "AL" ],
    [ "Alaska", "AK" ],
    [ "Arizona", "AZ" ],
    [ "Arkansas", "AR" ],
    [ "California", "CA" ],
    [ "Colorado", "CO" ],
    [ "Connecticut", "CT" ],
    [ "Delaware", "DE" ],
    [ "Florida", "FL" ],
    [ "Georgia", "GA" ],
    [ "Hawaii", "HI" ],
    [ "Idaho", "ID" ],
    [ "Illinois", "IL" ],
    [ "Indiana", "IN" ],
    [ "Iowa", "IA" ],
    [ "Kansas", "KS" ],
    [ "Kentucky", "KY" ],
    [ "Louisiana", "LA" ],
    [ "Maine", "ME" ],
    [ "Maryland", "MD" ],
    [ "Massachusetts", "MA" ],
    [ "Michigan", "MI" ],
    [ "Minnesota", "MN" ],
    [ "Mississippi", "MS" ],
    [ "Missouri", "MO" ],
    [ "Montana", "MT" ],
    [ "Nebraska", "NE" ],
    [ "Nevada", "NV" ],
    [ "New Hampshire", "NH" ],
    [ "New Jersey", "NJ" ],
    [ "New Mexico", "NM" ],
    [ "New York", "NY" ],
    [ "North Carolina", "NC" ],
    [ "North Dakota", "ND" ],
    [ "Ohio", "OH" ],
    [ "Oklahoma", "OK" ],
    [ "Oregon", "OR" ],
    [ "Pennsylvania", "PA" ],
    [ "Puerto Rico", "PR" ],
    [ "Rhode Island", "RI" ],
    [ "South Carolina", "SC" ],
    [ "South Dakota", "SD" ],
    [ "Tennessee", "TN" ],
    [ "Texas", "TX" ],
    [ "Utah", "UT" ],
    [ "Vermont", "VT" ],
    [ "Virginia", "VA" ],
    [ "Washington", "WA" ],
    [ "West Virginia", "WV" ],
    [ "Wisconsin", "WI" ],
    [ "Wyoming", "WY" ]
  ]

  protected

  def validate
#    errors.add( "street", "must contain a street" ) if ( street.length == 0)
#    errors.add( "city", "must contain a city" ) if ( city.length == 0)
#    errors.add( "state", "must contain a state" ) if ( state.length == 0)
#    errors.add( "zip", "must contain a zip" ) if ( zip.length == 0)

    errors.add_to_base( "must contain a street." ) if ( street.blank?)
    errors.add_to_base( "must contain a city." ) if ( city.blank?)
    errors.add_to_base( "must contain a state." ) if ( state.blank?)
    errors.add_to_base( "must contain a zip." ) if ( zip.blank?)

    errors.add( "zip", "is the wrong format (<em>xxxxx</em> or <em>xxxxx-xxxx</em>)." ) unless ( zip.match(/\A\d{5}(-\d{4})?\Z/) or zip.blank?)
#    errors.add( "state", "should be a 2-letter abbreviation." ) unless ( (:state =~ /\A[\w]{2}\Z/ ) or state.length==0 )  #user will choose from select field
  end

end
