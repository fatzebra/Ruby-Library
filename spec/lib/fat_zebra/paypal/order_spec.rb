require 'spec_helper'

describe FatZebra::Paypal::Order do

  describe '.find', :vcr do
    subject(:order) { FatZebra::Paypal::Order.find(order_id) }

    context 'when found' do
      let(:order_id) { '071-PPO-U7RRMGM3OY3V2ZMN' }

      it 'returns order' do
        expect(order).to be_accepted
        expect(order.id).to eq(order_id)
      end
    end
  end

  describe '.search', :vcr do
    context 'with date filter' do
      subject(:orders) { FatZebra::Paypal::Order.search(from: start) }

      let(:start) { Date.parse('2020-08-05') }

      it 'returns orders created after start date' do
        created_date_check = orders.data.map { |rec| DateTime.strptime(rec.transaction_date, '%Y-%m-%dT%H:%M:%S%z').iso8601 >= start.iso8601 }

        is_expected.to be_accepted

        expect(orders.data).to be_a(Array)
        expect(orders.data.first).to be_a(FatZebra::Paypal::Order)
        expect(created_date_check.all?).to be(true)
      end
    end
  end
end