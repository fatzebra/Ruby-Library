require 'spec_helper'

describe FatZebra::Batch do
  let(:batch_path) { "#{File.dirname(__FILE__)}/../../fixtures/batch_test.csv" }

  let(:valid_batch_payload) {{
    file:     File.new(batch_path),
    filename: "BATCH-v1-PURCHASE-TEST-#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex}.csv"
  }}

  describe '.create', :vcr do
    subject(:batch) { FatZebra::Batch.create(valid_batch_payload) }

    context 'with file' do
      it { is_expected.to be_successful }
      it { expect(batch.reference).to_not be_empty }
    end

    context 'with path' do
      let(:valid_batch_payload) {{
        path:     batch_path,
        filename: "BATCH-v1-PURCHASE-TEST-#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex}.csv"
      }}

      it { is_expected.to be_successful }
      it { expect(batch.reference).to_not be_empty }
    end

    context 'validations' do
      let(:valid_batch_payload) {{}}

      it { expect{ batch }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.find', :vcr do
    let(:create) { FatZebra::Batch.create(valid_batch_payload) }
    subject(:batch) { FatZebra::Batch.find(create.reference) }

    it { is_expected.to be_successful }
    it { expect(batch.reference).to eq(create.reference) }
  end

  describe '.search', :vcr do
    subject(:batches) { FatZebra::Batch.search }

    it { is_expected.to be_successful }
    it { expect(batches.data.count).to be >= 2 }
    it { expect(batches.data.first).to be_a(FatZebra::Batch) }
  end

  describe '#result', :vcr do
    let(:create) { FatZebra::Batch.create(valid_batch_payload) }
    let(:batch) { FatZebra::Batch.find(create.reference) }

    it { expect(batch.result).to eq("Batch is not yet completed") }
  end

end
