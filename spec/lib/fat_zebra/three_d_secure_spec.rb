require 'spec_helper'

describe FatZebra::ThreeDSecure do
  describe '.setup', :vcr do
    subject(:setup) { described_class.setup(valid_setup_payload) }

    let(:valid_setup_payload) {{
      card_token: card_token
    }}

    let!(:credit_card) { FatZebra::Card.create(valid_three_d_secure_card_payload) }
    let(:card_token) { credit_card.token }

    context 'valid payload' do

      it 'returns expected keys' do
        expect(setup.keys.map(&:to_s)).to include(
          'reference_id',
          'access_token',
          'device_data_collection_url'
        )
      end
    end
  end

  describe '.check_enrollment', :vcr do
    subject(:enrollment) { described_class.check_enrollment(valid_enrollment_payload) }

    let!(:credit_card) { FatZebra::Card.create(valid_three_d_secure_card_payload) }

    let(:valid_enrollment_payload) {{
      merchant_username: merchant_username,
      card_token: credit_card.token,
      amount: 100,
      currency: 'AUD',
      reference: "ref-#{SecureRandom.hex(6)}",
      verification: '123',
      device_channel: 'BROWSER',
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

    let(:merchant_username) { "TEST "}

    # reference_id is returned from setup; for stability we call setup here.
    let(:reference_id) do
      described_class.setup(card_token: credit_card.token).reference_id
    end

    context 'with valid input' do
      it do
        expect(enrollment.errors).to be_nil
      end

      it 'returns expected keys' do
        expect(enrollment.keys.map(&:to_s)).to include('veres', 'pares', 'eci', 'cavv', 'xid', 'directory_server_transaction_id', 'specification_version', 'step_up_url', 'access_token')
      end

      it do
        expect(enrollment.veres).to be_truthy
        expect(enrollment.pares).to be_truthy
        expect(enrollment.eci).to be_nil
        expect(enrollment.eci).to be_nil
        expect(enrollment.cavv).to be_nil
        expect(enrollment.xid).to be_nil
        expect(enrollment.directory_server_transaction_id).to be_truthy
        expect(enrollment.specification_version).to be_truthy
        expect(enrollment.step_up_url).to be_truthy
        expect(enrollment.access_token).to be_truthy
      end
    end

    context 'validations' do
      let(:valid_enrollment_payload) {{}}

      it { expect { enrollment }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.validate_authentication', :vcr do
    subject(:validation) { described_class.validate_authentication(valid_three_d_secure_card_payload) }

    let!(:credit_card) { FatZebra::Card.create(valid_three_d_secure_card_payload) }

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
      device_channel: 'BROWSER',
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

    context 'validations' do
      let(:valid_validation_payload) {{}}

      it { expect { validation }.to raise_error(FatZebra::RequestValidationError) }
    end
  end
end
