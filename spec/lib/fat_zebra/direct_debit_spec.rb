require 'spec_helper'

describe FatZebra::DirectDebit do

  let(:valid_direct_debit_payload) {{
    description:    'Confirmation',
    amount:         42,
    bsb:            '123-123',
    account_name:   'Test',
    account_number: '012345678'
  }}

  describe '.create', :vcr do
    subject(:direct_debit) { FatZebra::DirectDebit.create(valid_direct_debit_payload) }

    it { is_expected.to be_accepted }
    it { expect(direct_debit.bsb).to eq(valid_direct_debit_payload[:bsb]) }
    it { expect(direct_debit.reference).to_not be_empty }
    it { expect(direct_debit.id).to_not be_empty }

    context 'validations' do
      context 'valid' do
        before { valid_direct_debit_payload[:amount] = 42.42 }

        it { is_expected.to be_accepted }
      end

      context 'failed' do
        let(:valid_direct_debit_payload) {{}}

        it { expect{ direct_debit }.to raise_error(FatZebra::RequestValidationError) }
      end
    end
  end

  describe '.find', :vcr do
    let!(:create) { FatZebra::DirectDebit.create(valid_direct_debit_payload) }
    subject(:direct_debit) { FatZebra::DirectDebit.find(create.reference) }

    it { is_expected.to be_accepted }
    it { expect(direct_debit.reference).to eq(create.reference) }
  end

  describe '.search', :vcr do
    let!(:start) { Time.now }
    subject(:direct_debits) { FatZebra::DirectDebit.search }

    before { 2.times { |i| FatZebra::DirectDebit.create(valid_direct_debit_payload) } }

    it { is_expected.to be_accepted }
    it { expect(direct_debits.data.count).to be >= 2 }
  end

  describe '.delete', :vcr do
    let(:create) { FatZebra::DirectDebit.create(valid_direct_debit_payload) }
    subject(:direct_debit) { FatZebra::DirectDebit.delete(create.id) }

    it { is_expected.to be_accepted }
  end

end
