require "test_helper"

class VerificationTest < ActiveSupport::TestCase
  include GoingPostal
  
  
  
  def test_verification
    sloppy_address = Address.new(:street => '3558 Jeffreson Av', :city => 'StL', :state => 'Missouri', :zip => '63118')
    valid_address = Address.new(:street => '3558 S Jefferson Ave', :city => 'St Louis', :state => 'MO', :zip => '63118')
    assert_equal valid_address, sloppy_address.suggest_valid_address
  end
  
  
  
end