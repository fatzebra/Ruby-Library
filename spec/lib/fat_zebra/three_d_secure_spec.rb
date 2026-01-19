require 'spec_helper'

describe FatZebra::ThreeDSecure do
  describe '.setup', :vcr do
    subject(:setup) { described_class.setup(valid_setup_payload) }

    let(:valid_setup_payload) {{
      card_token: card_token
    }}

    let!(:credit_card) { FatZebra::Card.create(valid_credit_card_payload) }
    let(:card_token) { credit_card.token }

    context 'with invalid input' do

      it do
        valid_setup_payload[:card_token] = 'INVALID'
        is_expected.not_to be_accepted
        expect(setup.errors.join).to match(/Card not found|card_token/i)
      end

      it do
        valid_setup_payload.delete(:card_token)
        expect { setup }.to raise_error(FatZebra::RequestValidationError)
      end
    end

    context 'with valid input' do
      it do
        is_expected.to be_accepted
        expect(setup.errors).to be_empty
      end

      it 'returns expected keys' do
        is_expected.to be_accepted
        expect(setup.keys).to include('reference_id')
        expect(setup.reference_id).to be_truthy
      end
    end
  end

  describe '.check_enrollment', :vcr do
    subject(:enrollment) { described_class.check_enrollment(valid_enrollment_payload) }

    let!(:credit_card) { FatZebra::Card.create(valid_credit_card_payload) }

    let(:valid_enrollment_payload) {{
      merchant_username: merchant_username,
      card_token: credit_card.token,
      amount: 100,
      currency: 'AUD',
      reference: "ref-#{SecureRandom.hex(6)}",
      verification: '123',
      device_channel: 'browser',
      reference_id: reference_id,
      return_url: 'https://example.com/3ds/return',
      acs_window_size: '05',
      browser_accept_content: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      browser_language: 'en-AU',
      browser_java_enabled: false,
      browser_color_depth: 24,
      browser_screen_height: 1080,
      browser_screen_width: 1920,
      browser_time_difference: 0,
      browser_user_agent: 'RSpec'
    }}

    # In the SDK these are usually configured; keep them as lets so projects can override via spec helpers.
    let(:merchant_username) { ENV.fetch('FATZEBRA_MERCHANT_USERNAME', 'test') }

    # reference_id is returned from setup; for stability we call setup here.
    let(:reference_id) do
      described_class.setup(card_token: credit_card.token).reference_id
    end

    context 'with invalid input' do
      it do
        valid_enrollment_payload[:card_token] = 'INVALID'
        is_expected.not_to be_accepted
        expect(enrollment.errors.join).to match(/Card not found|card_token/i)
      end

      it do
        valid_enrollment_payload[:currency] = 'INVALID'
        is_expected.not_to be_accepted
        expect(enrollment.errors.join).to match(/INVALID is not valid for this merchant|currency/i)
      end

      it do
        valid_enrollment_payload[:amount] = 'INVALID'
        is_expected.not_to be_accepted
        expect(enrollment.errors.join).to match(/Amount is invalid|amount/i)
      end

      it do
        valid_enrollment_payload.delete(:merchant_username)
        expect { enrollment }.to raise_error(FatZebra::RequestValidationError)
      end

      it do
        valid_enrollment_payload.delete(:reference_id)
        expect { enrollment }.to raise_error(FatZebra::RequestValidationError)
      end

      it do
        valid_enrollment_payload.delete(:return_url)
        expect { enrollment }.to raise_error(FatZebra::RequestValidationError)
      end
    end

    context 'with valid input' do
      it do
        is_expected.to be_accepted
        expect(enrollment.errors).to be_empty
      end

      it 'returns expected keys' do
        is_expected.to be_accepted
        expect(enrollment.keys).to include('enrolled', 'version', 'card_bin')
      end

      it do
        expect(enrollment.enrolled).to be_truthy
        expect(enrollment.version).to be_truthy
        expect(enrollment.card_bin).to be_truthy
      end
    end

    context 'validations' do
      let(:valid_enrollment_payload) {{}}

      it { expect { enrollment }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.validate_authentication', :vcr do
    subject(:validation) { described_class.validate_authentication(valid_validation_payload) }

    let!(:credit_card) { FatZebra::Card.create(valid_credit_card_payload) }

    let(:merchant_username) { ENV.fetch('FATZEBRA_MERCHANT_USERNAME', 'test') }

    let(:reference_id) do
      described_class.setup(card_token: credit_card.token).reference_id
    end

    let(:authentication_transaction_id) do
      described_class.check_enrollment(valid_enrollment_payload).authentication_transaction_id
    end

    let(:valid_enrollment_payload) {{
      merchant_username: merchant_username,
      card_token: credit_card.token,
      amount: 100,
      currency: 'AUD',
      reference: "ref-#{SecureRandom.hex(6)}",
      verification: '123',
      device_channel: 'browser',
      reference_id: reference_id,
      return_url: 'https://example.com/3ds/return',
      acs_window_size: '05',
      browser_accept_content: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      browser_language: 'en-AU',
      browser_java_enabled: false,
      browser_color_depth: 24,
      browser_screen_height: 1080,
      browser_screen_width: 1920,
      browser_time_difference: 0,
      browser_user_agent: 'RSpec'
    }}

    let(:valid_validation_payload) {{
      merchant_username: merchant_username,
      card_token: credit_card.token,
      amount: 100,
      currency: 'AUD',
      authentication_transaction_id: authentication_transaction_id
    }}

    context 'with invalid input' do
      it do
        valid_validation_payload[:card_token] = 'INVALID'
        is_expected.not_to be_accepted
        expect(validation.errors.join).to match(/Card not found|card_token/i)
      end

      it do
        valid_validation_payload[:amount] = 'INVALID'
        is_expected.not_to be_accepted
        expect(validation.errors.join).to match(/Amount is invalid|amount/i)
      end

      it do
        valid_validation_payload[:authentication_transaction_id] = 'INVALID'
        is_expected.not_to be_accepted
        expect(validation.errors.join).to match(/authentication_transaction_id|transaction/i)
      end
    end

    context 'with valid input' do
      it do
        is_expected.to be_accepted
        expect(validation.errors).to be_empty
      end

      it 'returns expected keys' do
        is_expected.to be_accepted
        expect(validation.keys).to include('decision', 'authentication_transaction_id')
      end
    end

    context 'validations' do
      let(:valid_validation_payload) {{}}

      it { expect { validation }.to raise_error(FatZebra::RequestValidationError) }
    end
  end
end
