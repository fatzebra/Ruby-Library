require 'spec_helper'

describe FatZebra::DirectCredit do

  let(:valid_direct_credit_payload) {{
    description:    'Confirmation',
    amount:         42.0,
    bsb:            '123-123',
    account_name:   'Test',
    account_number: '012345678'
  }}

  describe '.create', :vcr do
    subject(:direct_credit) { FatZebra::DirectCredit.create(valid_direct_credit_payload) }

    it { is_expected.to be_accepted }
    it { expect(direct_credit.bsb).to eq(valid_direct_credit_payload[:bsb]) }
    it { expect(direct_credit.reference).to_not be_empty }
    it { expect(direct_credit.id).to_not be_empty }

    context 'validations' do
      context 'valid' do
        before { valid_direct_credit_payload[:amount] = 42.42 }

        it { is_expected.to be_accepted }
      end

      context 'failed' do
        let(:valid_direct_credit_payload) {{}}

        it { expect{ direct_credit }.to raise_error(FatZebra::RequestValidationError) }
      end

      context 'failed with non-float' do
        let(:valid_direct_credit_payload) {{
          description:    'Confirmation',
          amount:         123,
          bsb:            '123-123',
          account_name:   'Test',
          account_number: '012345678'
        }}

        it { expect{ direct_credit }.to raise_error(FatZebra::RequestValidationError) }
      end
    end
  end

  describe '.find', :vcr do
    let!(:create) { FatZebra::DirectCredit.create(valid_direct_credit_payload) }
    subject(:direct_credit) { FatZebra::DirectCredit.find(create.reference) }

    it { is_expected.to be_accepted }
    it { expect(direct_credit.reference).to eq(create.reference) }
    it { expect(direct_credit.amount).to be_instance_of(Float) }
  end

  describe '.search', :vcr do
    let!(:start) { Time.now }
    subject(:direct_credits) { FatZebra::DirectCredit.search }

    before { 2.times { |i| FatZebra::DirectCredit.create(valid_direct_credit_payload) } }

    it { is_expected.to be_accepted }
    it { expect(direct_credits.data.count).to be >= 2 }
  end

  describe '.delete', :vcr do
    let(:create) { FatZebra::DirectCredit.create(valid_direct_credit_payload) }
    subject(:direct_credit) { FatZebra::DirectCredit.delete(create.id) }

    it { is_expected.to be_accepted }
  end

end
