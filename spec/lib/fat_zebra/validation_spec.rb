require 'spec_helper'

describe FatZebra::Validation do
  let(:klass) { Class.new }

  before { klass.send(:extend, FatZebra::Validation) }

  describe '#valid?' do
    before { klass.validates(:test, required: true, on: :create) }

    it { expect(klass.valid?({}, :create)).to be_falsey }
    it { expect(klass.valid?({ test: 'valid' }, :create)).to be_truthy }
    it { expect(klass.valid?({}, :update)).to be_truthy }
  end

  describe '#valid!' do
    before { klass.validates(:test, required: true, on: :create) }

    it { expect { klass.valid!({}, :create) }.to raise_error(FatZebra::RequestValidationError) }
  end

end
