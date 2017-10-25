#!/usr/bin/env ruby

require 'csv'
require 'net/http'

class Saleoptima

  SALEOPTIMA_URL = URI('https://post.salesoptima.com/wcmpost.aspx')

  def self.call(input_object)
    new(input_object).send(:post)
  end

  private

  attr_reader :customer

  def initialize(input_object)
    @customer = input_object
  end

  def post
    result = Net::HTTP.post_form(SALEOPTIMA_URL, parse_data)
    if result.code == "200"
      puts "successfuly sent #{customer.first_name}"
    else
      raise "Can't send #{customer.first_name} to SO "
    end
  end

  def parse_data
    {
      LinkCode:  					'CF/3OS2IS9HUWAC/PNFM76FFIFYN',
      txtContactSettings:		 					0,
      txtContactOverWrite:	 					1,
      txtPostMethod:	 					      1,
      txtLeadOverWrite:							  1,
      txtCheckDupByPhone:							1,
      txtContactDupProcID:						23707,
      txtContactNewProcID:						23707,
      txtFirstName:								    customer.first_name,
      txtLastName:								    customer.last_name,
      txtEmail:									      customer.email,
      txtPhone:									      customer.formated_phone,
      txtWebSite:									    customer.url,
      txtCompanyName:									customer.company,
      txtComments:									  customer.comment,
      txtForceOwner:								  customer.force_owner
    }
  end
end

Customer = Struct.new(:full_name, :company, :url, :phone, :email, :comment, :force_owner) do
  def first_name
    full_name || company
  end

  def last_name
    full_name || company
  end

  def formated_phone
    return phone.gsub(/\D/, '') if phone
    nil
  end
end

CSV.foreach('customers.csv', :headers => true) do |row|
  customer = Customer.new(
    row["Full Name"],
    row["Company"],
    row["Targeted Url"],
    row["Phone Number"],
    row["Email"],
    row["Comments"],
    row["Force Owner"]
  )
  Saleoptima.call(customer)
end
