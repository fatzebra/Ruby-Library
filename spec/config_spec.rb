require 'spec_helper'

describe FatZebra::Config do
  it "should configure with a block" do
    FatZebra.configure do
      username "TEST"
      token "TEST"
      sandbox true
    end

    FatZebra.config.username.should == "TEST"
    FatZebra.config.token.should == "TEST"
    FatZebra.config.sandbox.should be_true
  end

  it "should configure from a hash" do
    config = FatZebra.configure(:username => "TEST", :token => "TEST", :sandbox => true)
    config.username.should == 'TEST'
  end

  it "should prepare a new gateway when configured" do
    FatZebra.configure do
      username "TEST"
      token "TEST"
      test_mode true
      sandbox true
      options :headers => {"A" => "B"}
    end

    FatZebra.gateway.should_not be_nil
  end

  it "should raise an error when trying to access the gateway before it is configured" do
    FatZebra.config = nil
    lambda { FatZebra.gateway }.should raise_exception(FatZebra::GatewayError)
  end
end	