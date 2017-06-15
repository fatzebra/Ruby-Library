require 'spec_helper'

describe FatZebra::Refund do
  let(:valid_refund_payload) {{
    transaction_id: transaction_id,
    amount:         10000,
    reference:      reference
  }}

  describe '.create', :vcr do
    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    let(:transaction_id) { purchase.transaction_id }
    let(:reference) { purchase.reference }
    subject(:refund) { FatZebra::Refund.create(valid_refund_payload) }

    it { is_expected.to be_successful }
    it { expect(refund.authorization.to_s).to_not be_empty }
    it { expect(refund.id).to_not be_empty }
    it { expect(refund.card_holder).to eq('Matthew Savage') }
    it { expect(refund.transaction_id).to_not eq(transaction_id) }
    it { expect(refund.reference).to eq(reference) }
    it { expect(refund.currency).to eq('AUD') }
    it { expect(refund.response_code).to eq('00') }
    it { expect(refund.metadata).to eq({}) }

    context 'validations' do
      let(:valid_refund_payload) {{}}

      it { expect{ refund }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.find', :vcr do
    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    let(:transaction_id) { purchase.transaction_id }
    let(:reference) { purchase.reference }
    let(:create) { FatZebra::Refund.create(valid_refund_payload) }

    subject(:direct_credit) { FatZebra::Refund.find(create.reference) }

    it { is_expected.to be_successful }
    it { expect(direct_credit.reference).to eq(create.reference) }
  end

  describe '.search', :vcr do
    subject(:direct_credits) { FatZebra::Refund.search }

    before do
      2.times do |i|
        purchase = FatZebra::Purchase.create(valid_purchase_payload)
        FatZebra::Refund.create(amount: 10000, reference: purchase.reference, transaction_id: purchase.transaction_id)
      end
    end

    it { is_expected.to be_successful }
    it { expect(direct_credits.data.count).to be >= 2 }
  end

  describe '#void', :vcr do
    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    let(:transaction_id) { purchase.transaction_id }
    let(:reference) { purchase.reference }
    let(:refund) { FatZebra::Refund.create(valid_refund_payload) }

    before { refund.void() }

    it { is_expected.to_not be_successful }
    it { expect(refund.message).to eq('Voided') }
    it { expect(refund).to be_a(FatZebra::Refund) }
  end

end
