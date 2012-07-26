require 'spec_helper'

describe FatZebra::Response do
	it "should make the raw response available" do
		response = {
			"successful" => true,
			"errors" => [],
			"test" => false,
			"response" => {
				"authorization" => "55355",
        		"id" => "001-P-12345AA",
        		"card_number" => "XXXXXXXXXXXX1111",
		        "card_holder" => "John Smith",
		        "card_expiry" => "10/2011",
		        "card_token"  => "a1bhj98j",
		        "amount" => 349,
		        "authorized" => true,
		        "reference" => "ABC123",
		        "message" => "Approved"
			}
		}
		r = FatZebra::Response.new(response)
		r.raw.should == response
	end
end