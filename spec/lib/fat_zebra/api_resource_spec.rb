require 'spec_helper'

describe FatZebra::APIResource do

  describe '#request' do
    subject(:resource) { FatZebra::APIResource.request(:post, '/test') }

    context 'with errors' do
      before { allow(FatZebra::Request).to receive(:execute).and_raise(FatZebra::RequestError.new(response)) }

      context 'with Net::HTTPUnprocessableEntity' do
        let(:response) { double('response', code: '422', code_type: Net::HTTPUnprocessableEntity, body: {}.to_json, message: 'failed') }

        it { expect { resource }.to_not raise_error }
      end

      context 'with Net::HTTPBadRequest' do
        let(:response) { double('response', code: '400', code_type: Net::HTTPBadRequest, body: {}.to_json, message: 'failed') }

        it { expect { resource }.to raise_error(FatZebra::RequestError) }
      end
    end
  end

end
