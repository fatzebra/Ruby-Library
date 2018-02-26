require 'spec_helper'

describe FatZebra::Request do
  describe '#initalize' do
    subject do
      FatZebra::Request
        .new(params)
        .http
    end
    let(:params) do
      {
        url: 'https://cool.dudes/v2/swagtopia.json',
      }.merge!(proxy_params)
    end
    let(:formatted_proxy) { [host, port].join(':') }
    let(:formatted_host) { URI.parse(host).host }
    let(:host) { "http://squidward.net" }
    let(:port) { 6969 }

    context 'with default params' do
      let(:proxy_params) {{}}

      it 'does not use a proxy configuration' do
        expect(subject.proxy?).to eq(false)
      end
    end

    context 'with env var specifying http proxy' do
      let(:proxy_params) {{}}
      before do
        allow(ENV).to receive(:[]).with("NO_PROXY").and_return(nil)
        allow(ENV).to receive(:[]).with("no_proxy").and_return(nil)
        allow(ENV).to receive(:[]).with("http_proxy").and_return(formatted_proxy)
      end

      it 'draws the proxy configuration from the environment var' do
        expect(subject.proxy?).to eq(true)
        expect(subject.proxy_from_env?).to eq(true)
        expect(subject.proxy_address).to eq(formatted_host)
        expect(subject.proxy_port).to eq(port)
      end
    end

    context 'with custom http_proxy params to the constructor passed via initializer or similar' do
      let(:proxy_params) do
        {
          proxy: formatted_proxy
        }
      end

      it 'draws the proxy host and port configuration from the environment var' do
        expect(subject.proxy?).to eq(true)
        expect(subject.proxy_from_env?).to eq(false)
        expect(subject.proxy_address).to eq(formatted_host)
        expect(subject.proxy_port).to eq(port)
      end
    end
  end
end
