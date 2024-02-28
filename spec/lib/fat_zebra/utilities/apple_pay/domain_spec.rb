require 'spec_helper'

describe FatZebra::Utilities::ApplePay::Domain do

  describe '.register!', :vcr do
    subject(:create) { FatZebra::Utilities::ApplePay::Domain.register!(domain, valid_payload) }

    let!(:domain) { "www.example99.com" }
    let!(:valid_payload) {{
      async: false
    }}

    it "registers the domain" do
      expect(create).to be_accepted
      expect(create.domain).to eq(domain)
      expect(create.status).to eq("Active")
    end
    # it { is_expected.to be_accepted }
    # it { expect(create.domain).to eq(domain) }
    # it { expect(create.status).to eq("Active") }

    # context 'validations' do
    #   let(:customer_valid_payload) {{}}

    #   it { expect{ customer }.to raise_error(FatZebra::RequestValidationError) }
    # end
  end

  describe '.find!', :vcr do
    subject(:find) { FatZebra::Utilities::ApplePay::Domain.find!(domain) }
    let!(:domain) { "www.example.com" }

    it "fetches the domain" do
      expect(find).to be_accepted
      expect(find.domain).to eq(domain)
      expect(find.status).to eq("Active")
    end

    # it { is_expected.to be_accepted }
    # it { expect(find.status).to eq("Active") }
    # it { expect(find.domain).to eq(domain) }
  end

  describe '.delete!', :vcr do
    subject(:delete) { FatZebra::Utilities::ApplePay::Domain.delete!(domain) }
    let!(:domain) { "www.example99.com" }

    it "deletes the domain" do
      expect(delete).to be_accepted
    end

    # it { is_expected.to be_accepted }
  end
end
