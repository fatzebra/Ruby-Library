require 'spec_helper'

describe FatZebra::Config do
  let(:params) {{
    token:       'my-token',
    username:    'my-username'
  }}

  subject(:config) { FatZebra::Config.new(params) }

  describe  '#initialize' do
    it { expect(config.valid!).to be_truthy }
    it { expect(config.token).to eq(params[:token]) }
    it { expect(config.username).to eq(params[:username]) }
    it { expect(config.gateway).to eq('gateway.fatzebra.com.au') }
    it { expect(config.test_mode).to be_falsey }
    it { expect(config.http_secure).to be_truthy }
    it { expect(config.api_version).to eq('v1.0') }

    context 'with all params' do
      let(:params) {{
        token:       'my-token',
        username:    'my-username',
        gateway:     'my-gateway',
        test_mode:   'my-test_mode',
        http_secure: 'my-http_secure',
        api_version: 'my-api_version',
        proxy:       'my-proxy'
      }}

      it { expect(config.valid!).to be_truthy }
      it { expect(config.gateway).to eq(params[:gateway]) }
      it { expect(config.test_mode).to eq(params[:test_mode]) }
      it { expect(config.http_secure).to eq(params[:http_secure]) }
      it { expect(config.api_version).to eq(params[:api_version]) }
      it { expect(config.proxy).to eq(params[:proxy]) }
    end

    %i[username token].each do |field|
      context "validate #{field}" do
        let(:params) {{ token: 'my-token', username: 'my-username' }.merge(field => '')}

        it { expect { config.valid! }.to raise_error(FatZebra::ConfigurationError, "#{field} can't be blank") }
      end
    end

    context 'with gateway' do
      before { expect(config.valid!).to be_truthy }

      context 'with production' do
        subject(:config) { FatZebra::Config.new(params.merge(gateway: :production)) }

        it { expect(config.gateway).to eq('gateway.fatzebra.com.au') }
      end
    end

    context 'remove http' do
      let(:params) {{
        token:    'my-token',
        username: 'my-username',
        gateway:  'http://my-gateway',
        proxy:    'https://my-proxy'
      }}

      it { expect(config.gateway).to eq('my-gateway') }
    end

  end
end
