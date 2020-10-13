require 'spec_helper'

describe FatZebra::Paypal::BillingAgreement do

  describe '.find', :vcr do
    subject(:billing_agreement) { FatZebra::Paypal::BillingAgreement.find(id) }

    context 'when found' do
      let(:id) { '071-PBA-PYG1L6M4CV4DYHTZ' }

      it 'returns billing_agreement' do
        expect(billing_agreement).to be_accepted
        expect(billing_agreement.id).to eq(id)
      end
    end
  end

  describe '.search', :vcr do
    context 'with date filter' do
      subject(:billing_agreements) { FatZebra::Paypal::BillingAgreement.search(from: start) }

      let(:start) { Date.parse('2020-08-05') }

      it 'returns records created after start date' do
        created_date_check = billing_agreements.data.map { |rec| DateTime.strptime(rec.created_at, '%Y-%m-%dT%H:%M:%S%z').iso8601 >= start.iso8601 }

        is_expected.to be_accepted

        expect(billing_agreements.data).to be_a(Array)
        expect(billing_agreements.data.first).to be_a(FatZebra::Paypal::BillingAgreement)
        expect(created_date_check.all?).to be(true)
      end
    end
  end

  describe '#charge', :vcr do
    let(:id) { '071-PBA-PYG1L6M4CV4DYHTZ' }

    context 'Valid payload' do
      subject(:charge) { FatZebra::Paypal::BillingAgreement.charge(id, valid_charge_billing_agreement_payload) }

      it 'returns a new order record' do
        is_expected.to be_accepted
        is_expected.to be_successful

        expect(charge).to be_a(FatZebra::Paypal::Order)
        expect(charge.billing_agreement_id).to eq(id)
        expect(charge.payment_source).to eq('BILLING_AGREEMENT')
        expect(charge.id).to include('PPO')
        expect(charge.captures.count).to eq(1)
      end
    end

    context 'Invalid payload' do
      subject(:charge) { FatZebra::Paypal::BillingAgreement.charge(id, {}) }

      it 'failed to execute call' do
        expect{ charge }.to raise_error(FatZebra::RequestValidationError)
      end
    end
  end
end