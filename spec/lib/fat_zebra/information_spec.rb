require 'spec_helper'

describe FatZebra::Information do

  describe '.ping', :vcr do
    let(:nonce) { '262ca5679c2dd86ac866200a7b57fab0' }
    subject(:ping) { FatZebra::Information.ping(nonce) }

    it { expect(ping.timestamp.to_s).to_not be_empty }
    it { expect(ping.echo).to eq(nonce) }
  end

end
