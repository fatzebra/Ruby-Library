require 'spec_helper'

describe FatZebra::Authenticate do
  describe '.session', :vcr do
    subject(:token) { FatZebra::Authenticate.session(valid_3ds_token_payload) }

    let(:valid_3ds_token_payload) {{
      currency: 'AUD',
      amount: 100
    }}

    it 'returns JWT with given params' do
      is_expected.to be_accepted
      expect(token.jwt).to be_truthy
    end

    it 'returns JWT with no amount' do
      valid_3ds_token_payload.delete(:amount)
      is_expected.to be_accepted
      expect(token.jwt).to be_truthy
    end

    it 'returns error when currency is invalid' do
      valid_3ds_token_payload[:currency] = 'INVALID'
      is_expected.not_to be_accepted
      expect(token.errors).to be_a(Array)
      expect(token.errors.join).to match(/INVALID is not valid for this merchant. Permitted currencies:/)
    end

    it 'returns error when amount is invalid' do
      valid_3ds_token_payload[:amount] = 'INVALID'
      is_expected.not_to be_accepted
      expect(token.errors).to eq(['Amount is invalid'])
    end    
  end

  describe '.decode_session', :vcr do
    subject(:decoded) { FatZebra::Authenticate.decode_session(token: jwt) }

    context 'when token is valid' do
      let(:valid_3ds_token_payload) {{
        currency: 'AUD',
        amount: 100
      }}
      let(:jwt) { FatZebra::Authenticate.session(valid_3ds_token_payload).jwt }

      it 'decodes JWT' do
        is_expected.to be_accepted
        expect(decoded.keys).to include('processor_transaction_id', 'consumer_session_id', 'error_number', 'error_description')
        expect(decoded.errors).to be_empty
      end
    end

    context 'when token is invalid' do
      let(:jwt) { 'INVALID TOKEN' }

      it 'returns error when invalid token' do
        is_expected.not_to be_accepted
        expect(decoded.errors).to eq(['Decoding JWT failed: The token is invalid'])
      end
    end
  end

  describe '.authenticate', :vcr do
    subject(:authenticate) { FatZebra::Authenticate.authenticate(valid_sca_authentication_payload) }
    let!(:credit_card) { FatZebra::Card.create(valid_credit_card_payload) }

    context 'with invalid input' do
      before do
        valid_sca_authentication_payload[:sca].merge!(valid_sca_enrollment_payload)
      end

      it do
        valid_sca_authentication_payload[:card_token] = 'INVALID'
        is_expected.not_to be_accepted
        expect(authenticate.errors.join).to match(/Card not found/)
      end

      it do
        valid_sca_authentication_payload[:sca] = {}
        is_expected.not_to be_accepted
        expect(authenticate.errors.join).to match(/Invalid input data/)
      end

      it do
        valid_sca_authentication_payload[:currency] = 'INVALID'
        is_expected.not_to be_accepted
        expect(authenticate.errors.join).to match(/INVALID is not valid for this merchant. Permitted currencies:/)
      end

      it do
        valid_sca_authentication_payload[:amount] = 'INVALID'
        is_expected.not_to be_accepted
        expect(authenticate.errors.join).to match(/3DS authenticate request failed: amount must be filled/)
      end
    end

    context 'with frictionless response' do
      before do
        valid_credit_card_payload[:card_number] = '4000000000001000'
        valid_sca_authentication_payload[:sca].merge!(valid_sca_enrollment_payload)
      end

      it do
        is_expected.to be_accepted
        expect(authenticate.keys).to include('enrolled', 'acs_url', 'version', 'card_bin', 'authentication_transaction_id')
        expect(authenticate.errors).to be_empty
      end

      it do
        expect(authenticate.enrolled).to be_truthy
        expect(authenticate.version).to be_truthy
        expect(authenticate.card_bin).to be_truthy
        expect(authenticate.authentication_transaction_id).to be_truthy
      end
    end

    context 'with challenge response' do
      before do
        valid_credit_card_payload[:card_number] = '4000000000001091'
        valid_sca_authentication_payload[:sca].merge!(valid_sca_enrollment_payload)
      end

      it do
        is_expected.to be_accepted
        expect(authenticate.keys).to include('enrolled', 'version', 'card_bin', 'authentication_transaction_id')
        expect(authenticate.errors).to be_empty
      end

      it do
        expect(authenticate.enrolled).to be_truthy
        expect(authenticate.version).to be_truthy
        expect(authenticate.card_bin).to be_truthy
        expect(authenticate.authentication_transaction_id).to be_truthy
      end
    end

    context 'with type = validation' do
      subject(:authenticate) { FatZebra::Authenticate.authenticate(valid_sca_authentication_payload) }

      before do
        allow(FatZebra::Authenticate).to receive(:authenticate)
          .with(valid_sca_authentication_payload)
          .and_return(FatZebra::FatZebraObject.initialize_from(validation_response.to_json))

        valid_credit_card_payload[:card_number] = '4000000000001091'
        valid_sca_authentication_payload[:sca][:type] = 'validation'
        valid_sca_authentication_payload[:sca].merge!(valid_sca_validation_payload)
      end

      let(:validation_response) do
        {
          successful: true,
          response: {
            action: {
              proceed: true
            },
            version: '2.2.0',
            enrolled: 'Y',
            cavv: SecureRandom.hex,
            xid: SecureRandom.hex,
            pares: 'Y',
            eci: '05',
            authentication_transaction_id: SecureRandom.hex,
            card_bin: '400000',
            request_id: SecureRandom.hex,
            decision: 'ACCEPT'
          },
          errors: [],
          test: true
        }
      end

      it do
        is_expected.to be_accepted
        expect(authenticate.keys).to include('enrolled', 'version', 'card_bin', 'authentication_transaction_id', 'cavv', 'eci', 'xid', 'pares')
        expect(authenticate.errors).to be_empty
      end
    end
    
    context 'validations' do
      let(:valid_sca_authentication_payload) {{}}

      it { expect{ authenticate }.to raise_error(FatZebra::RequestValidationError) }
    end
  end
end
