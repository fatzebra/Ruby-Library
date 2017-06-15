require 'spec_helper'

describe FatZebra::BankAccount do

  let(:valid_bank_account_payload) {{
    bsb:            '123-123',
    account_name:   'Test name',
    account_number: '012345678'
  }}

  describe '.create', :vcr do
    subject(:bank_account) { FatZebra::BankAccount.create(valid_bank_account_payload) }

    it { is_expected.to be_successful }
    it { expect(bank_account.id).to_not be_empty }

    context 'validations' do
      let(:valid_bank_account_payload) {{}}

      it { expect{ bank_account }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.search', :vcr do
    subject(:bank_accounts) { FatZebra::BankAccount.search }

    before { 2.times { |i| FatZebra::BankAccount.create(valid_bank_account_payload) } }

    it { is_expected.to be_successful }
    it { expect(bank_accounts.data.count).to be >= 2 }
    it { expect(bank_accounts.data.first).to be_a(FatZebra::BankAccount) }
  end

end
