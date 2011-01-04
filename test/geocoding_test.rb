require "test_helper"

class AddressTest < ActiveSupport::TestCase
  include GoingPostal
  
  
  
  def test_geocoding
    address = Address.new(:street => '3558 S Jefferson Ave', :city => 'St Louis', :state => 'MO', :zip => '63118')
    address.geocode
    assert_not_nil address.latitude
    assert_not_nil address.longitude
    p "lat, long:  #{address.latitude}, #{address.longitude}"
  end
  
  
  
end