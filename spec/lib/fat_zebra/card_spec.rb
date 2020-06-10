require 'spec_helper'

describe FatZebra::Card do

  describe '.create', :vcr do
    subject(:credit_card) { FatZebra::Card.create(valid_credit_card_payload) }

    it { is_expected.to be_accepted }
    it { expect(credit_card.token).to_not be_empty }
    it { expect(credit_card.card_holder).to eq('Matthew Savage') }
    it { expect(credit_card.card_number).to_not be_empty }
    it { expect(credit_card.card_type).to eq('MasterCard') }
    it { expect(credit_card.authorized?).to be_truthy }

    context 'validations' do
      let(:valid_credit_card_payload) {{}}

      it { expect{ credit_card }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.update', :vcr do
    let(:valid_credit_card_update_payload) {{
      card_expiry: DateTime.new(2050, 2, 3).strftime('%m/%Y'),
    }}

    let(:create) { FatZebra::Card.create(valid_credit_card_payload) }
    subject(:credit_card) { FatZebra::Card.update(create.token, valid_credit_card_update_payload) }

    it { is_expected.to be_accepted }
    it { expect(credit_card.token).to eq(create.token) }
    it { expect(credit_card.card_expiry).to_not eq(create.card_expiry) }

    context 'validations' do
      let(:valid_credit_card_update_payload) {{}}

      it { expect{ credit_card }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.find', :vcr do
    let(:create) { FatZebra::Card.create(valid_credit_card_payload) }
    subject(:card) { FatZebra::Card.find(create.token) }

    it { is_expected.to be_accepted }
    it { expect(card.token).to eq(create.token) }
  end

end
