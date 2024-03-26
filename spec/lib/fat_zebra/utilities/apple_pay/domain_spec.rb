require 'spec_helper'

describe FatZebra::Utilities::ApplePay::Domain do

  describe '.list!', :vcr do
    subject(:list) { FatZebra::Utilities::ApplePay::Domain.list! }

    it "fetches the merchant domains" do
      expect(list).to be_accepted
      expect(list.data.length).to eq(2)
      expect(list.data.first.raw).to eq(
        {
          "domain" => "example.com", 
          "status" => "Active"
        }
      )
      expect(list.data.last.raw).to eq(
        {
          "domain" => "example2.com", 
          "status" => "Active"
        }
      )
    end
  end

  describe '.register!', :vcr do
    subject(:create) { FatZebra::Utilities::ApplePay::Domain.register!(domain, valid_payload) }

    let!(:domain) { "www.example99.com" }
    let!(:valid_payload) {{
      async: false
    }}

    it "creates the domain" do
      expect(create).to be_accepted
      expect(create.domain).to eq(domain)
      expect(create.status).to eq("Active")
    end
  end

  describe '.find!', :vcr do
    subject(:find) { FatZebra::Utilities::ApplePay::Domain.find!(domain) }
    let!(:domain) { "www.example.com" }

    it "fetches the domain" do
      expect(find).to be_accepted
      expect(find.domain).to eq(domain)
      expect(find.status).to eq("Active")
    end
  end

  describe '.delete!', :vcr do
    subject(:delete) { FatZebra::Utilities::ApplePay::Domain.delete!(domain) }
    let!(:domain) { "www.example99.com" }

    it "deletes the domain" do
      expect(delete).to be_accepted
    end
  end
end
