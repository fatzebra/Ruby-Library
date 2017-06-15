require 'spec_helper'

describe FatZebra::Customer do

  describe '.create', :vcr do
    subject(:customer) { FatZebra::Customer.create(customer_valid_payload) }

    it { is_expected.to be_accepted }
    it { expect(customer.id).to_not be_empty }
    it { expect(customer.first_name).to eq(customer_valid_payload[:first_name]) }
    it { expect(customer.last_name).to eq(customer_valid_payload[:last_name]) }
    it { expect(customer.card_token).to_not be_empty }
    it { expect(customer.bank_account).to be_nil }

    context 'validations' do
      let(:customer_valid_payload) {{}}

      it { expect{ customer }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.search', :vcr do
    subject(:purchases) { FatZebra::Customer.search }

    it { is_expected.to be_accepted }
    it { expect(purchases.data.count).to be >= 2 }
    it { expect(purchases.data.first).to be_a(FatZebra::Customer) }
  end

  describe '.find', :vcr do
    let!(:create) { FatZebra::Customer.create(customer_valid_payload) }
    subject(:customer) { FatZebra::Customer.find(create.reference) }

    it { is_expected.to be_accepted }
    it { expect(customer.reference).to eq(create.reference) }
  end

  describe '.update', :vcr do
    let(:create) { FatZebra::Customer.create(customer_valid_payload) }
    subject(:customer) { FatZebra::Customer.update(create.id, first_name: 'New Name') }

    it { is_expected.to be_accepted }
    it { expect(customer.first_name).to eq('New Name') }
  end

  describe '.delete', :vcr do
    let(:create) { FatZebra::Customer.create(customer_valid_payload) }
    subject(:customer) { FatZebra::Customer.delete(create.id) }

    it { is_expected.to be_accepted }
  end

end
