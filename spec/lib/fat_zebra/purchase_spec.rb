require 'spec_helper'

describe FatZebra::Purchase do

  describe '.create', :vcr do
    subject(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(purchase.card_holder).to eq(valid_purchase_payload[:card_holder]) }
    it { expect(purchase.currency).to eq('AUD') }
    it { expect(purchase.reference).to_not be_empty }
    it { expect(purchase.transaction_id).to_not be_empty }
    it { expect(purchase.decimal_amount).to eq(100) }
    it { expect(purchase.card_type).to eq('MasterCard') }
    it { expect(purchase.card_category).to eq('Credit') }
    it { expect(purchase.card_token).to_not be_empty }
    it { expect(purchase.addendum_data).to eq({}) }
    it { expect(purchase.metadata).to eq({ "authorization_tracking_id" => "", "original_transaction_reference" => "" }) }
    it { expect(purchase.response_code).to eq('00') }

    context 'bad request' do
      subject(:purchase) { FatZebra::Purchase.create(valid_purchase_payload.merge(currency: 'XXX' )) }

      it { is_expected.to_not be_accepted }
      it { is_expected.to_not be_successful }
    end

    context 'validations' do
      let(:valid_purchase_payload) {{}}

      it { expect{ purchase }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.find', :vcr do
    let!(:create) { FatZebra::Purchase.create(valid_purchase_payload) }
    subject(:purchase) { FatZebra::Purchase.find(create.reference) }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(purchase.reference).to eq(create.reference) }
    it { expect(purchase.transaction_id).to eq(create.transaction_id) }
  end

  describe '.search', :vcr do
    let!(:start) { Date.parse('2017-07-03') }
    subject(:purchases) { FatZebra::Purchase.search(from: start) }

    before { 2.times { |i| FatZebra::Purchase.create(valid_purchase_payload.merge(reference: "#{SecureRandom.hex}-#{i}")) } }

    it { is_expected.to be_accepted }
    it { expect(purchases.data.count).to be >= 2 }
    it { expect(purchases.data.first).to be_a(FatZebra::Purchase) }
  end

  describe '#refund', :vcr do
    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    subject(:refund) { purchase.refund }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(refund).to be_a(FatZebra::Refund) }
  end

  describe '#capture', :vcr do
    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload.merge(capture: false)) }
    subject(:capture) { purchase.capture }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(capture).to be_a(FatZebra::Purchase) }
  end

  describe '.void', :vcr do
    let(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    subject(:void) { FatZebra::Purchase.void(purchase.id) }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(void.message).to eq('Voided') }
    it { expect(void).to be_a(FatZebra::Purchase) }
  end

  describe '#void', :vcr do
    subject(:purchase) { FatZebra::Purchase.create(valid_purchase_payload) }
    before { expect(purchase.void).to be_truthy }

    it { is_expected.to be_accepted }
    it { is_expected.to be_successful }
    it { expect(purchase.message).to eq('Voided') }
    it { expect(purchase).to be_a(FatZebra::Purchase) }
  end

  describe '.settlement', :vcr do
    before { 2.times { |i| FatZebra::Purchase.create(valid_purchase_payload.merge(reference: "#{SecureRandom.hex}-#{i}")) } }

    subject(:settlement) { FatZebra::Purchase.settlement(from: Date.parse('2017/06/22'), to: Date.parse('2017-06-27')) }

    it { is_expected.to be_accepted }
    it { expect(settlement.data.count).to be >= 2 }
    it { expect(settlement.data.first).to be_a(FatZebra::Purchase) }
  end

end
