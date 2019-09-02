require 'spec_helper'

describe FatZebra::Authorise do

  describe '.jwt_token', :vcr do
    subject(:token) { FatZebra::Authorise.jwt_token(valid_3ds_token_payload) }

    let(:valid_3ds_token_payload) {{
      reference_id: 'xxxx-xxxx-xxxx',
      confirm_url: 'https://example.com',
      order_number: 'xxxx-xxxx-xxxx',
      currency_code: '036',
      amount: 100
    }}

    it 'returns JWT with given params' do
      is_expected.to be_accepted
      expect(token.jwt).to be_truthy
      expect(token.reference_id).to be_truthy
    end

    it 'returns JWT with some params' do
      valid_3ds_token_payload.delete(:reference_id)
      is_expected.to be_accepted
      expect(token.jwt).to be_truthy
      expect(token.reference_id).to be_truthy
    end

    it 'returns JWT with no params' do
      valid_3ds_token_payload.clear
      is_expected.to be_accepted
      expect(token.jwt).to be_truthy
      expect(token.reference_id).to be_truthy
    end
  end

  describe '.authorise', :vcr do
    subject(:authorise) { FatZebra::Authorise.authorise(valid_3ds_authorise_payload) }

    context 'with invalid input' do
      before do
        valid_3ds_authorise_payload[:card_expiry] = DateTime.now.prev_month.strftime('%m/%Y')
      end

      it do
        is_expected.not_to be_accepted
        expect(authorise.errors).to match(/Error Validating Credit Card Expiration/)
      end
    end

    context 'with frictionless response' do
      before do
        valid_3ds_authorise_payload[:card_number] = '4000000000001000'
      end

      it do
        is_expected.to be_accepted
        expect(authorise.keys).to include('Enrolled', 'ACSUrl', 'CardBin', 'TransactionId')
        expect(authorise.errors).not_to be_truthy
      end

      it do
        expect(authorise.Enrolled).to eq('Y')
        expect(authorise.ACSUrl).not_to be_truthy
        expect(authorise.CardBin).to be_truthy
        expect(authorise.ErrorNo).to eq('0')
        expect(authorise.ErrorDesc).not_to be_truthy
        expect(authorise.CardBrand).to be_truthy
        expect(authorise.TransactionId).to be_truthy
      end
    end

    context 'with challenge response' do
      before do
        valid_3ds_authorise_payload[:card_number] = '4111111111111111'
      end

      it do
        is_expected.to be_accepted
        expect(authorise.keys).to include('Enrolled', 'ACSUrl', 'CardBin', 'TransactionId')
        expect(authorise.errors).not_to be_truthy
      end
      
      it do
        expect(authorise.Enrolled).to eq('Y')
        expect(authorise.ACSUrl).to be_truthy
        expect(authorise.CardBin).to be_truthy
        expect(authorise.ErrorNo).to eq('0')
        expect(authorise.ErrorDesc).not_to be_truthy
        expect(authorise.CardBrand).to be_truthy
        expect(authorise.TransactionId).to be_truthy
      end
    end
    
    context 'validations' do
      let(:valid_3ds_authorise_payload) {{}}

      it { expect{ authorise }.to raise_error(FatZebra::RequestValidationError) }
    end
  end
end
