require 'spec_helper'

describe FatZebra::Refund do
  let(:valid_refund_payload) {{
    transaction_id: transaction_id,
    amount:         10000,
    reference:      reference
  }}

  describe '.create', :vcr do
    subject(:refund) { FatZebra::Refund.create(valid_refund_payload) }

    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    let(:transaction_id) { purchase.transaction_id }
    let(:reference) { purchase.reference }

    it { is_expected.to be_accepted }
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
    subject(:found_refund) { FatZebra::Refund.find(created_refund.reference) }

    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    let(:transaction_id) { purchase.transaction_id }
    let(:reference) { purchase.reference }
    let(:created_refund) { FatZebra::Refund.create(valid_refund_payload) }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(found_refund.reference).to eq(created_refund.reference) }
  end

  describe '.search', :vcr do
    subject(:found_refunds) { FatZebra::Refund.search }

    let(:created_refunds) do
      purchase = FatZebra::Purchase.create(valid_purchase_payload)
      [
        FatZebra::Refund.create(amount: 1000, reference: SecureRandom.hex, transaction_id: purchase.transaction_id),
        FatZebra::Refund.create(amount: 1000, reference: SecureRandom.hex, transaction_id: purchase.transaction_id),
      ]
    end

    before { created_refunds }

    it "responds with the newly-created refunds" do
      is_expected.to be_accepted
      expect(found_refunds.data.map(&:id)).to include(*created_refunds.map(&:id))
    end
  end

  describe '#void', :vcr do
    subject(:refund) { FatZebra::Refund.create(valid_refund_payload).void }

    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    let(:transaction_id) { purchase.transaction_id }
    let(:reference) { purchase.reference }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(refund.message).to eq('Voided') }
    it { expect(refund).to be_a(FatZebra::Refund) }
  end

  describe '#declined?' do
    subject { refund.declined? }

    let(:refund) { described_class.initialize_from({ 'response' => { 'refunded' => refunded } }) }

    context do
      let(:refunded) { 'Declined' }
      it { is_expected.to be(true) }
    end

    context do
      let(:refunded) { 'Approved' }
      it { is_expected.to be(false) }
    end
  end
end
