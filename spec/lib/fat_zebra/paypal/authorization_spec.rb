require 'spec_helper'

describe FatZebra::Paypal::Authorization do

  describe '.find', :vcr do
    subject(:authorization) { FatZebra::Paypal::Authorization.find(authorization_id) }

    context 'when found' do
      let(:authorization_id) { '071-PPA-3AM3CXFFKMFYI3QM' }

      it 'returns authorization' do
        expect(authorization).to be_accepted
        expect(authorization.id).to eq(authorization_id)
        expect(authorization.order).to include('PPO')
      end
    end
  end

  describe '.search', :vcr do
    context 'with date filter' do
      subject(:authorizations) { FatZebra::Paypal::Authorization.search(from: start) }

      let(:start) { Date.parse('2020-08-05') }

      it 'returns records created after start date' do
        created_date_check = authorizations.data.map { |rec| DateTime.strptime(rec.transaction_date, '%Y-%m-%dT%H:%M:%S%z').iso8601 >= start.iso8601 }

        is_expected.to be_accepted

        expect(authorizations.data).to be_a(Array)
        expect(authorizations.data.first).to be_a(FatZebra::Paypal::Authorization)
        expect(created_date_check.all?).to be(true)
      end
    end
  end

  describe '#capture', :vcr do
    subject(:capture_record) { FatZebra::Paypal::Authorization.capture(authorization_id, params_for_capture) }

    let(:authorization_id) { '071-PPA-3AM3CXFFKMFYI3QM' }
    let(:capture_amount) { 200 }
    let(:note) { 'test capture $2' }
    let(:params_for_capture) do
      {
        amount: capture_amount,
        final_Capture: false,
        note_to_payer: note
      }
    end

    it 'returns a new capture record' do
      is_expected.to be_accepted
      is_expected.to be_successful

      expect(capture_record).to be_a(FatZebra::Paypal::Capture)
      expect(capture_record.id).to include('PPC')
      expect(capture_record.order).to include('PPO')
      expect(capture_record.amount).to eq(capture_amount)
      expect(capture_record.note_to_payer).to eq(note)
      expect(capture_record.balance_available_for_capture).to be > 0
    end
  end

  describe '#void', :vcr do
    subject(:voided_authorization_record) { FatZebra::Paypal::Authorization.void(authorization_id) }

    let(:authorization_id) { '071-PPA-XB5CXLVNIGCNTB8V' }

    it 'returns a voided capture record' do
      is_expected.to be_accepted
      is_expected.to be_successful

      expect(voided_authorization_record).to be_a(FatZebra::Paypal::Authorization)
      expect(voided_authorization_record.id).to include('PPA')
      expect(voided_authorization_record.response_code).to eq('00')
      expect(voided_authorization_record.balance_available_for_capture).to eq(0)
    end
  end
end