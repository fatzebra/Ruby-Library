require 'spec_helper'

describe FatZebra::Paypal::Capture do

  describe '.find', :vcr do
    subject(:capture) { FatZebra::Paypal::Capture.find(capture_id) }

    context 'when found' do
      let(:capture_id) { '071-PPC-TUOHT8YJHBY7SBJU' }

      it 'returns capture' do
        expect(capture).to be_accepted
        expect(capture.id).to eq(capture_id)
        expect(capture.order).to include('PPO')
      end
    end
  end

  describe '.search', :vcr do
    context 'with date filter' do
      subject(:captures) { FatZebra::Paypal::Capture.search(from: start) }

      let(:start) { Date.parse('2020-08-05') }

      it 'returns records created after start date' do
        created_date_check = captures.data.map { |rec| DateTime.strptime(rec.transaction_date, '%Y-%m-%dT%H:%M:%S%z').iso8601 >= start.iso8601 }

        is_expected.to be_accepted

        expect(captures.data).to be_a(Array)
        expect(captures.data.first).to be_a(FatZebra::Paypal::Capture)
        expect(created_date_check.all?).to be(true)
      end
    end
  end

  describe '#refund', :vcr do
    subject(:refund_record) { FatZebra::Paypal::Capture.refund(capture_id, params_for_refund) }

    let(:capture_id) { '071-PPC-TUOHT8YJHBY7SBJU' }
    let(:refund_amount) { 100 }
    let(:params_for_refund) do
      {
        amount: refund_amount,
        note_to_payer: 'test note'
      }
    end

    it 'returns a new refund record' do
      is_expected.to be_accepted
      is_expected.to be_successful

      expect(refund_record).to be_a(FatZebra::Paypal::Refund)
      expect(refund_record.amount).to eq(refund_amount)
      expect(refund_record.note_to_payer).to eq('test note')
      expect(refund_record.id).to include('PPR')
      expect(refund_record.order).to include('PPO')
    end
  end
end