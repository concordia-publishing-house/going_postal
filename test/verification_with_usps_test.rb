require "test_helper"

class VerificationWithUspsTest < ActiveSupport::TestCase
  include GoingPostal
  
  def setup
    # default configuration
    Address::Verification.api = :usps
    Api::Usps.user_id = '669CONCO5165'
    Api::Usps.server = :production
    
    @sloppy_address = Address.new(:street => '1234 Fake St', :city => 'Nowhere', :state => 'AA', :zip => '')
  end
  
  
  
  def test_verifying_via_usps_without_credentials
    Api::Usps.user_id = nil
    Api::Usps.server = :test
    assert_raises(Api::Usps::CredentialsNotSupplied) { @sloppy_address.suggest_valid_address }
  end
  
  
  
  def test_verifying_via_usps_without_credentials
    Api::Usps.user_id = 'FAKECREDENTIALS'
    Api::Usps.server = nil
    assert_raises(Api::Usps::ServerNotSupplied) { @sloppy_address.suggest_valid_address }
  end
  
  
  
  def test_canned_request_on_test_server
    Api::Usps.server = :test
    canned_address = Address.new(:street => '6406 Ivy Lane', :city => 'Greenbelt', :state => 'MD', :zip => '')
    expected_address = Address.new(:street => "6406 IVY LN", :city => "GREENBELT", :state => "MD", :zip => "20770-1440")
    returned_address = canned_address.suggest_valid_address
    assert_equal expected_address, returned_address
  end
  
  
  
  # def test_verification
  #   sloppy_address = Address.new(:street => '3558 Jeffreson Av', :city => 'StL', :state => 'Missouri', :zip => '63118')
  #   valid_address = Address.new(:street => '3558 S Jefferson Ave', :city => 'St Louis', :state => 'MO', :zip => '63118')
  #   assert_equal valid_address, sloppy_address.suggest_valid_address
  # end
  # 
  # 
  # 
  # def test_verification_of_missing_address
  #   sloppy_address = Address.new(:street => '1234 Fake St', :city => 'Nowhere', :state => 'AA', :zip => '')
  #   assert_equal Address.empty, sloppy_address.suggest_valid_address
  # end
  
  
  
end