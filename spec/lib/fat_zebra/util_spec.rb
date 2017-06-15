require 'spec_helper'

describe FatZebra::Util do

  describe '#compact' do
    it { expect(FatZebra::Util.compact(test: nil, other: 'test')).to eq(other: 'test') }
  end

  describe '#encode_parameters' do
    it { expect(FatZebra::Util.encode_parameters(id: 42, other: 'test')).to eq("id=42&other=test") }
  end

  describe '#underscore' do
    it { expect(FatZebra::Util.underscore('Model')).to eq("model") }
    it { expect(FatZebra::Util.underscore('MyModel')).to eq("my_model") }
  end

  describe '#format_dates_in_hash' do
    let (:date) { DateTime.new(2050, 2, 3) }

    it { expect(FatZebra::Util.format_dates_in_hash(date: date)).to eq(date: '2050/02/03') }
  end

end
