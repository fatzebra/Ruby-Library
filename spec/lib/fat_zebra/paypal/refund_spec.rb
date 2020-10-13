require 'spec_helper'

describe FatZebra::Paypal::Refund do

  describe '.find', :vcr do
    subject(:refund) { FatZebra::Paypal::Refund.find(refund_id) }

    context 'when found' do
      let(:refund_id) { '071-PPR-SRR9FP7ZKXT9IXU3' }

      it 'returns refund' do
        expect(refund).to be_accepted
        expect(refund.id).to eq(refund_id)
        expect(refund.order).to include('PPO')
      end
    end
  end

  describe '.search', :vcr do
    context 'with date filter' do
      subject(:refunds) { FatZebra::Paypal::Refund.search(from: start) }

      let(:start) { Date.parse('2020-08-05') }

      it 'returns all refund records created after start date' do
        created_date_check = refunds.data.map { |rec| DateTime.strptime(rec.transaction_date, '%Y-%m-%dT%H:%M:%S%z').iso8601 >= start.iso8601 }

        is_expected.to be_accepted

        expect(refunds.data).to be_a(Array)
        expect(refunds.data.first).to be_a(FatZebra::Paypal::Refund)
        expect(created_date_check.all?).to be(true)
      end
    end
  end
end