require 'spec_helper'

describe FatZebra::Authenticate do

  describe '.jwt_token', :vcr do
    subject(:token) { FatZebra::Authenticate.jwt_token(valid_3ds_token_payload) }

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

  describe '.decode_jwt', :vcr do
    subject(:decoded) { FatZebra::Authenticate.decode_jwt(token: jwt) }

    context 'when token is valid' do
      let(:jwt) { FatZebra::Authenticate.jwt_token({}).jwt }

      it 'decodes JWT' do
        is_expected.to be_accepted
        expect(decoded.keys).to include('payload')
        expect(decoded.payload).to be_a(Hash)
        expect(decoded.errors).not_to be_truthy
      end
    end

    context 'when token is invalid' do
      let(:jwt) { 'INVALID TOKEN' }

      it 'returns error when invalid token' do
        is_expected.not_to be_accepted
        expect(decoded.errors).to match(/The token is invalid/)
      end
    end
  end

  describe '.authenticate', :vcr do
    subject(:authenticate) { FatZebra::Authenticate.authenticate(valid_sca_authenticate_payload) }

    context 'with invalid input' do
      before do
        valid_sca_authenticate_payload[:card_expiry] = DateTime.now.prev_month.strftime('%m/%Y')
      end

      it do
        is_expected.not_to be_accepted
        expect(authenticate.errors).to match(/Error Validating Credit Card Expiration/)
      end
    end

    context 'with frictionless response' do
      before do
        valid_sca_authenticate_payload[:card_number] = '4000000000001000'
      end

      it do
        is_expected.to be_accepted
        expect(authenticate.keys).to include('Enrolled', 'ACSUrl', 'CardBin', 'TransactionId')
        expect(authenticate.errors).not_to be_truthy
      end

      it do
        expect(authenticate.Enrolled).to eq('Y')
        expect(authenticate.ACSUrl).not_to be_truthy
        expect(authenticate.CardBin).to be_truthy
        expect(authenticate.ErrorNo).to eq('0')
        expect(authenticate.ErrorDesc).not_to be_truthy
        expect(authenticate.CardBrand).to be_truthy
        expect(authenticate.TransactionId).to be_truthy
      end
    end

    context 'with challenge response' do
      before do
        valid_sca_authenticate_payload[:card_number] = '4111111111111111'
      end

      it do
        is_expected.to be_accepted
        expect(authenticate.keys).to include('Enrolled', 'ACSUrl', 'CardBin', 'TransactionId')
        expect(authenticate.errors).not_to be_truthy
      end
      
      it do
        expect(authenticate.Enrolled).to eq('Y')
        expect(authenticate.ACSUrl).to be_truthy
        expect(authenticate.CardBin).to be_truthy
        expect(authenticate.ErrorNo).to eq('0')
        expect(authenticate.ErrorDesc).not_to be_truthy
        expect(authenticate.CardBrand).to be_truthy
        expect(authenticate.TransactionId).to be_truthy
      end
    end
    
    context 'validations' do
      let(:valid_sca_authenticate_payload) {{}}

      it { expect{ authenticate }.to raise_error(FatZebra::RequestValidationError) }
    end
  end
end
