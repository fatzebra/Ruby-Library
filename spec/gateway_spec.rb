require 'spec_helper'

TEST_USER = "TEST"
TEST_TOKEN = "TEST"
TEST_LOCAL = ENV["TEST_LOCAL"] == "true" || false

describe FatZebra::Gateway do
	before :each do
		# Setup the gateway for testing
		server = TEST_LOCAL == true ? "fatapi.dev" : "gateway.sandbox.fatzebra.com.au"
		@gw = FatZebra::Gateway.new(TEST_USER, TEST_TOKEN, server, {:secure => !TEST_LOCAL})
	end

	it "should require username and token are provided" do
		lambda { FatZebra::Gateway.new("test", nil) }.should raise_exception(FatZebra::InvalidArgumentError)
	end

	it "should require that the gateway_server arg is not nil or empty" do
		lambda { FatZebra::Gateway.new("test", "test", "") }.should raise_exception(FatZebra::InvalidArgumentError)	
	end

	it "should load a valid instance of the gateway" do
		@gw.ping.should be_true
	end

	it "should perform a purchase" do
		result = @gw.purchase(10000, {:card_holder => "Matthew Savage", :number => "5555555555554444", :expiry => "05/2013", :cvv => 123}, "TEST#{rand}", "1.2.3.4")
		result.should be_successful
		result.errors.should be_empty
	end

	it "should fetch a purchase" do
		result = @gw.purchase(10000, {:card_holder => "Matthew Savage", :number => "5555555555554444", :expiry => "05/2013", :cvv => 123}, "TES#{rand}T", "1.2.3.4")
		purchase = @gw.purchases(:id => result.purchase.id)
		purchase.id.should == result.purchase.id
	end

	it "should fetch a purchase via reference" do
		ref = "TES#{rand}T"
		result = @gw.purchase(10000, {:card_holder => "Matthew Savage", :number => "5555555555554444", :expiry => "05/2013", :cvv => 123}, ref, "1.2.3.4")

		purchases = @gw.purchases(:reference => ref)
		purchases.id.should == result.purchase.id
	end

	it "should fetch purchases within a date range" do
		start = Time.now
		5.times do |i|
			@gw.purchase(10000, {:card_holder => "Matthew Savage", :number => "5555555555554444", :expiry => "05/2013", :cvv => 123}, "TEST#{rand(1000)}-#{i}", "1.2.3.4")
		end

		purchases = @gw.purchases(:from => start, :to => Time.now)
		purchases.count.should >= 5
	end

	it "should fetch purchases with a from date" do
		start = Time.now
		5.times do |i|
			@gw.purchase(10000, {:card_holder => "Matthew Savage", :number => "5555555555554444", :expiry => "05/2013", :cvv => 123}, "TEST#{rand(1000)}-#{i}", "1.2.3.4")
		end

		purchases = @gw.purchases(:from => start)
		purchases.count.should >= 5
	end

	it "should refund a transaction" do
		purchase = @gw.purchase(10000, {:card_holder => "Matthew Savage", :number => "5555555555554444", :expiry => "05/2013", :cvv => 123}, "TES#{rand}T", "1.2.3.4")
		result = @gw.refund(purchase.result.id, 100, "REFUND-#{purchase.result.id}")

		result.should be_successful
		result.result.successful.should be_true
	end

	it "should tokenize a card" do
		response = @gw.tokenize("M Smith", "5123456789012346", "05/2013", "123")
		response.should be_successful
		response.result.token.should_not be_nil
	end
end