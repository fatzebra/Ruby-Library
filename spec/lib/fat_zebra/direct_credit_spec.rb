require 'spec_helper'

describe FatZebra::DirectCredit do

  let(:valid_direct_credit_payload) {{
    description:    'Confirmation',
    amount:         42,
    bsb:            '123-123',
    account_name:   'Test',
    account_number: '012345678'
  }}

  describe '.create', :vcr do
    subject(:direct_credit) { FatZebra::DirectCredit.create(valid_direct_credit_payload) }

    it { is_expected.to be_successful }
    it { expect(direct_credit.bsb).to eq(valid_direct_credit_payload[:bsb]) }
    it { expect(direct_credit.reference).to_not be_empty }
    it { expect(direct_credit.id).to_not be_empty }

    context 'validations' do
      let(:valid_direct_credit_payload) {{}}

      it { expect{ direct_credit }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.find', :vcr do
    let!(:create) { FatZebra::DirectCredit.create(valid_direct_credit_payload) }
    subject(:direct_credit) { FatZebra::DirectCredit.find(create.reference) }

    it { is_expected.to be_successful }
    it { expect(direct_credit.reference).to eq(create.reference) }
  end

  describe '.search', :vcr do
    let!(:start) { Time.now }
    subject(:direct_credits) { FatZebra::DirectCredit.search }

    before { 2.times { |i| FatZebra::DirectCredit.create(valid_direct_credit_payload) } }

    it { is_expected.to be_successful }
    it { expect(direct_credits.data.count).to be >= 2 }
  end

  describe '.delete', :vcr do
    let(:create) { FatZebra::DirectCredit.create(valid_direct_credit_payload) }
    subject(:direct_credit) { FatZebra::DirectCredit.delete(create.id) }

    it { is_expected.to be_successful }
  end

end
