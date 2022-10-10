require 'spec_helper'

describe FatZebra::Reports::Payouts do
  describe '.for_date', :vcr do
    context 'with valid date object' do
      let(:date) { Date.parse('2022-10-10') }
      let(:response) { payout_report }
      subject(:payout_report) { FatZebra::Reports::Payouts.for_date(date) }
  
      it { is_expected.to be_accepted }
      it { expect(payout_report.payout_date).to eq(date.strftime('%Y-%m-%d')) }
      it { expect(payout_report.payouts).to be_instance_of(Array) }
    end
  
    context 'without valid date object' do
      subject(:payout_report) { FatZebra::Reports::Payouts.for_date('not-a-date') }
  
      it 'raises a date usage error' do
        expect { payout_report }.to raise_error(FatZebra::Reports::Errors::MustUseDateObject)
      end
    end
  end
end
