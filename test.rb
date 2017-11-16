#!/usr/bin/env ruby

require 'csv'
require 'net/http'

class Saleoptima

  SALEOPTIMA_URL = URI('https://post.salesoptima.com')

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
      LinkCode:  					'CF/3OS2IS9HUWAC/PNFM76FF',
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
      txtComments:							customer.format_comment,
      txtForceOwner:								  customer.force_owner
    }
  end
end

Customer = Struct.new(:full_name, :company, :url, :phone, :email, :comment, :force_owner, :source) do
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

  def format_comment
    [
      " ",
      "#{source}" ,
      "#{comment}" ,
      "#{url}",
    ].join("\n").to_s
  end
end

CSV.foreach('customers.csv', :headers => true, encoding: "iso-8859-1:UTF-8") do |row|
  customer = Customer.new(
    row["Full Name"],
    row["Company"],
    row["Targeted Url"],
    row["Phone Number"],
    row["Email"],
    row["Comments"],
    row["Force Owner"],
    row["Source"]
  )
  Saleoptima.call(customer)
end
