require 'rubygems'
require 'awesome_usps'


# ===============================================================================
# GoingPostal::Api::Usps
# ===============================================================================
# 
#   This module relies on USPS Web Tools
#   http://www.usps.com/webtools/
#   
#   In particular, it requires the use of the Address Information APIs
#   You will need a username supplied by USPS and also permission to use
#   the Address Information APIs to make use of the module.
#   
#   You can receive a username by registering here for a Web Tools account:
#   https://secure.shippingapis.com/registration/
#   
#   You can request permission to use the Address Information APIs here:
#   http://www.usps.com/webtools/webtoolsapirequestform.htm
# 
# ===============================================================================

module GoingPostal
  class Api
    module Usps
      
      
      
      mattr_accessor :user_id
      mattr_accessor :server
      
      
      
      class CredentialsNotSupplied < StandardError
      end
      
      class ServerNotSupplied < StandardError
      end
      
      class AddressNotFound < StandardError
      end
      
      
      
      def self.find_address!(address)
        find_address(address) || raise(AddressNotFound)
      end
      
      def self.find_address(address)
        find_addresses(address).first
      end
      
      def self.find_addresses(address)
        results = make_request(address.to_hash)
        results.map {|hash| usps_hash_to_address(hash)}
      end
      
      
      
    private
      
      
      
      def self.make_request(address_hash)
        user_id = ::GoingPostal::Api::Usps.user_id || raise(CredentialsNotSupplied)
        server  = ::GoingPostal::Api::Usps.server  || raise(ServerNotSupplied)
        
        api = AwesomeUsps::Api.new(:username => user_id, :server => server)
        api.verify_address(address_hash)
      end
      
      
      
      def self.usps_hash_to_address(hash)
        Address.new({
          :street => format_street(hash[:address1], hash[:address2]),
          :city => hash[:city],
          :state => hash[:state],
          :zip => format_zip(hash[:zip5], hash[:zip4])
        })
      end
      
      def self.format_street(address1, address2)
        if address1.blank?;     address2
        elsif address2.blank?;  address1
        else                    "#{address1}\n#{address2}"
        end
      end
      
      def self.format_zip(zip5, zip4)
        if zip5.blank?;         ""
        elsif zip4.blank?;      zip5
        else                    "#{zip5}-#{zip4}"
        end
      end
      
      
      
    end
  end
end