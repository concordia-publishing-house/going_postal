require 'active_model'
require 'hash_accessors'

class Address < ActiveModel::Base
  include HashAccessors
  attr_reader :hash
  hash_readers_for :hash, [:street, :city, :state, :zip]
  
  STATES = [
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

  STATES_ABBREVIATED = [
    [ "AL" ],
    [ "AK" ],
    [ "AZ" ],
    [ "AR" ],
    [ "CA" ],
    [ "CO" ],
    [ "CT" ],
    [ "DE" ],
    [ "FL" ],
    [ "GA" ],
    [ "HI" ],
    [ "ID" ],
    [ "IL" ],
    [ "IN" ],
    [ "IA" ],
    [ "KS" ],
    [ "KY" ],
    [ "LA" ],
    [ "ME" ],
    [ "MD" ],
    [ "MA" ],
    [ "MI" ],
    [ "MN" ],
    [ "MS" ],
    [ "MO" ],
    [ "MT" ],
    [ "NE" ],
    [ "NV" ],
    [ "NH" ],
    [ "NJ" ],
    [ "NM" ],
    [ "NY" ],
    [ "NC" ],
    [ "ND" ],
    [ "OH" ],
    [ "OK" ],
    [ "OR" ],
    [ "PA" ],
    [ "PR" ],
    [ "RI" ],
    [ "SC" ],
    [ "SD" ],
    [ "TN" ],
    [ "TX" ],
    [ "UT" ],
    [ "VT" ],
    [ "VA" ],
    [ "WA" ],
    [ "WV" ],
    [ "WI" ],
    [ "WY" ]
  ]  


  def initialize(hash=nil)
    super()
    @hash = hash.is_a?(Hash) ? symbolize_keys(hash) : {}
    @hash.reverse_merge!(
      :street => "",
      :city => "",
      :state => "",
      :zip => "")
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
  
  def ==(other)
    other.is_a?(Address) ? (
      (self.street == other.street) &&
      (self.city == other.city) &&
      (self.state == other.state) &&
      (self.zip == other.zip)
    ) : false
  end

  def to_s
    if street.blank?
      ""
    else
      "#{street}\n#{city}, #{state}  #{zip}"
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
    address_as_string ? Address.new(YAML::load(address_as_string)) : Address.new
  end
  
  def self.converter(value)
    value.is_a?(Hash) ? Address.new(value) : nil
  end
  
  def to_hash
    # calling to_hash first will make sure the hash is a Hash and not HashWithIndifferentAccess
    symbolize_keys(@hash).to_hash
  end
  
  def to_yaml
    to_hash.to_yaml
  end

  def blank?
    (street.blank? and city.blank? and zip.blank?) # not "and state.blank?" because state can sometimes be set to a default
  end

  def exists?
    !blank?
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

protected

  def validate
    errors.add(:street, "cannot be blank") if street.blank?
    errors.add(:city, "cannot be blank") if city.blank?
    errors.add(:state, "cannot be blank") if state.blank?
    errors.add(:zip, "cannot be blank") if zip.blank?
    errors.add(:zip, "is the wrong format (<em>xxxxx</em> or <em>xxxxx-xxxx</em>).") if !zip.to_s.blank? and !zip.to_s.match(/\A\d{5}(-\d{4})?\Z/)
    #errors.add(:state, "should be a 2-letter abbreviation." ) unless ( (:state =~ /\A[\w]{2}\Z/ ) or state.length==0 )  #user will choose from select field
  end
  
end
