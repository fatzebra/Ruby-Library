require 'spec_helper'

describe FatZebra::PaymentPlan do
  let(:customer) { FatZebra::Customer.create(customer_valid_payload) }

  let(:payment_plan_valid_payload) {{
    payment_method: 'Credit Card',
    customer:       customer.id,
    reference:      SecureRandom.hex,
    setup_fee:      0,
    amount:         100,
    start_date:     '2015-07-16',
    frequency:      'Weekly',
    anniversary:    5,
    total_count:    5,
    total_amount:   500
  }}

  describe '.create', :vcr do
    subject(:payment_plan) { FatZebra::PaymentPlan.create(payment_plan_valid_payload) }

    it { is_expected.to be_successful }
    it { expect(payment_plan.id).to_not be_empty }
    it { expect(payment_plan.payments.count).to eq(5) }

    context 'validations' do
      let(:payment_plan_valid_payload) {{}}

      it { expect { payment_plan }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.find', :vcr do
    let!(:create) { FatZebra::PaymentPlan.create(payment_plan_valid_payload) }
    subject(:payment_plan) { FatZebra::PaymentPlan.find(create.reference) }

    it { is_expected.to be_successful }
    it { expect(payment_plan.reference).to eq(create.reference) }
    it { expect(payment_plan).to be_a(FatZebra::PaymentPlan) }
  end

  describe '.update', :vcr do
    let(:create) { FatZebra::PaymentPlan.create(payment_plan_valid_payload) }

    subject(:payment_plan) { FatZebra::PaymentPlan.update(create.id, new_status: 'Suspended') }

    it { is_expected.to be_successful }
    it { expect(payment_plan.status).to eq('Suspended') }
    it { expect(payment_plan).to be_a(FatZebra::PaymentPlan) }
  end

  context '#update', :vcr do
    let(:payment_plan) { FatZebra::PaymentPlan.new(payment_plan_valid_payload) }
    before { payment_plan.save }
    before { payment_plan.update(new_status: 'Suspended') }

    it { expect(payment_plan.status).to eq('Suspended') }
    it { expect(payment_plan).to be_a(FatZebra::PaymentPlan) }
  end

  describe '.delete', :vcr do
    let(:create) { FatZebra::PaymentPlan.create(payment_plan_valid_payload) }
    subject(:payment_plan) { FatZebra::PaymentPlan.delete(create.id) }

    it { is_expected.to be_successful }
  end

  describe '#destroy', :vcr do
    let(:payment_plan) { FatZebra::PaymentPlan.create(payment_plan_valid_payload) }
    before { payment_plan.destroy }

    it { expect(payment_plan.status).to eq('Cancelled') }
  end

  describe '#suspend!', :vcr  do
    let(:payment_plan) { FatZebra::PaymentPlan.new(payment_plan_valid_payload) }
    before { payment_plan.save }
    before { payment_plan.suspend! }

    it { expect(payment_plan.status).to eq('Suspended') }
    it { expect(payment_plan).to be_a(FatZebra::PaymentPlan) }
  end

  describe '#active!', :vcr  do
    let(:payment_plan) { FatZebra::PaymentPlan.new(payment_plan_valid_payload) }
    before { payment_plan.save }
    before { expect(payment_plan.suspend!.status).to eq('Suspended') }
    before { payment_plan.active! }

    it { expect(payment_plan.status).to eq('Active') }
    it { expect(payment_plan).to be_a(FatZebra::PaymentPlan) }
  end

end
