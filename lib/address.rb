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
    errors.add_to_base( "must contain a street." ) if ( street.blank?)
    errors.add_to_base( "must contain a city." ) if ( city.blank?)
    errors.add_to_base( "must contain a state." ) if ( state.blank?)
    errors.add_to_base( "must contain a zip." ) if ( zip.blank?)

    errors.add( "zip", "is the wrong format (<em>xxxxx</em> or <em>xxxxx-xxxx</em>)." ) unless ( zip.match(/\A\d{5}(-\d{4})?\Z/) or zip.blank?)
    #    errors.add( "state", "should be a 2-letter abbreviation." ) unless ( (:state =~ /\A[\w]{2}\Z/ ) or state.length==0 )  #user will choose from select field
  end


  
  def verify_address(address_info)
    raise "API key not specified.\nCall AddressStandardization::GoogleMaps.api_key = '...' before you call .standardize()." unless GoogleMaps.api_key

    address_info = address_info.stringify_keys

    address_str = [
      address_info["street"],
      address_info["city"],
      (address_info["state"] || address_info["province"]),
      address_info["zip"]
    ].compact.join(" ")
    url = "http://maps.google.com/maps/geo?q=#{address_str.url_escape}&output=xml&key=#{GoogleMaps.api_key}&oe=utf-8"
    AddressStandardization.debug "[GoogleMaps] Hitting URL: #{url}"
    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)
    return unless res.is_a?(Net::HTTPSuccess)

    content = res.body
    AddressStandardization.debug "[GoogleMaps] Response body:"
    AddressStandardization.debug "--------------------------------------------------"
    AddressStandardization.debug content
    AddressStandardization.debug "--------------------------------------------------"
    xml = Nokogiri::XML(content)
    xml.remove_namespaces! # good or bad? I say good.
    return unless xml.at("/kml/Response/Status/code").inner_text == "200"

    addr = {}

    addr[:street]   = get_inner_text(xml, '//ThoroughfareName').to_s
    addr[:city]     = get_inner_text(xml, '//LocalityName').to_s
    addr[:province] = addr[:state] = get_inner_text(xml, '//AdministrativeAreaName').to_s
    addr[:zip]      = addr[:postalcode] = get_inner_text(xml, '//PostalCodeNumber').to_s
    addr[:country]  = get_inner_text(xml, '//CountryName').to_s

    return if addr[:street] =~ /^\s*$/ or addr[:city]  =~ /^\s*$/

    Address.new(addr)
  end

  def get_inner_text(xml, xpath)
    lambda {|x| x && x.inner_text.upcase }.call(xml.at(xpath))
  end

end
