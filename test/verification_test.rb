require "test_helper"

class VerificationTest < ActiveSupport::TestCase
  include GoingPostal
  
  
  
  def test_verification
    sloppy_address = Address.new(:street => '3558 Jeffreson Av', :city => 'StL', :state => 'Missouri', :zip => '63118')
    valid_address = Address.new(:street => '3558 S Jefferson Ave', :city => 'St Louis', :state => 'MO', :zip => '63118')
    assert_equal valid_address, sloppy_address.suggest_valid_address
  end
  
  
  
  def test_verification_of_missing_address
    sloppy_address = Address.new(:street => '1234 Fake St', :city => 'Nowhere', :state => 'AA', :zip => '')
    assert_equal Address.empty, sloppy_address.suggest_valid_address
  end
  
  
  
  def test_verifying_via_usps_without_credentials
    Address::Verification.api = :usps
    assert_raises Api::Usps::CredentialsNotSupplied do
      sloppy_address = Address.new(:street => '1234 Fake St', :city => 'Nowhere', :state => 'AA', :zip => '')
      sloppy_address.suggest_valid_address
    end
  end
  
  
  
end