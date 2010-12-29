require 'active_support'
require 'active_support/core_ext'
require 'hash_accessors'
require 'active_model'
require 'active_model/validations'


class Address
  include ActiveModel::Validations
  include HashAccessors
  attr_reader :hash
  hash_readers_for :hash, [:street, :city, :state, :zip]
  
  
  
  validates_presence_of :city, :state, :street, :zip
  validates_format_of :zip, :with => /\A\d{5}(-\d{4})?\Z/, :message => "is the wrong format (<em>xxxxx</em> or <em>xxxxx-xxxx</em>)."
  
  
  
  def initialize(hash=nil)
    super()
    @hash = hash.is_a?(Hash) ? hash.symbolize_keys : {}
    @hash.reverse_merge!(
      :street => "",
      :city => "",
      :state => "",
      :zip => "")
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
    street.blank? ? "" : "#{street}\n#{city}, #{state}  #{zip}"
  end
  
  
  
  def as_json(options={})
    to_html
  end
  
  
  
  def to_html
    # todo 'h' is not recognized; but add html cleaning here
    # address.blank? ? "" : h(address).gsub(/ /, "&nbsp;").gsub(/\n/, "<br />")
    to_s.gsub(/ /, "&nbsp;").gsub(/\n/, "<br />")
    # html = "#{street}"
    # html << "<br/>" if(street and (street.length>0))
    # html << "#{city}, #{state}&nbsp;&nbsp;#{zip}" if(city and (city.length>0))
    # html
  end
  
  
  
  def self.loader(address_as_string)
    address_as_string ? Address.new(YAML::load(address_as_string)) : Address.new
  end
  
  
  
  def self.converter(value)
    value.is_a?(Hash) ? Address.new(value) : nil
  end
  
  
  
  def to_hash
    # calling to_hash first will make sure the hash is a Hash and not HashWithIndifferentAccess
    hash.to_hash
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
  
  
  
  # !todo: move to module
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
    [ "Washington D.C.", "DC" ],
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
    [ "DC" ],
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
  
  
  
end
