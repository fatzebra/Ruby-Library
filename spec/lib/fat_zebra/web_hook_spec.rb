require 'spec_helper'

describe FatZebra::WebHook do

  let(:valid_web_hook_payload) {{
    events:    '*',
    mode:      'Test',
    name:      'test hook',
    address:   'http://stage.example.com.au/v1/api/hook_listener'
  }}

  describe '.create', :vcr do
    subject(:web_hook) { FatZebra::WebHook.create(valid_web_hook_payload) }

    it { is_expected.to be_accepted }
    it { expect(web_hook.name).to eq('test hook') }
    it { expect(web_hook.id).to_not be_empty }

    context 'validations' do
      let(:valid_web_hook_payload) {{}}

      it { expect{ web_hook }.to raise_error(FatZebra::RequestValidationError) }
    end
  end

  describe '.search', :vcr do
    subject(:web_hooks) { FatZebra::WebHook.search }

    before { 2.times { |i| FatZebra::WebHook.create(valid_web_hook_payload) } }

    it { is_expected.to be_accepted }
    it { expect(web_hooks.data.count).to be >= 2 }
  end

  describe '#update', :vcr do
    subject(:web_hook) { FatZebra::WebHook.create(valid_web_hook_payload) }
    before { web_hook.update(name: 'New Test hook')}

    it { is_expected.to be_accepted }
    it { expect(web_hook.name).to eq('New Test hook') }
  end

  describe '.delete', :vcr do
    let(:create) { FatZebra::WebHook.create(valid_web_hook_payload) }
    subject(:web_hook) { FatZebra::WebHook.delete(create.id) }

    it { is_expected.to be_accepted }
  end

  describe '#update payload' do
    subject(:web_hook) { FatZebra::WebHook.initialize_from(api_response('test hook')) }

    def api_response(name)
      { 'successful' => true, 'response' => { 'id' => '071-WH-1', 'name' => name, 'mode' => 'Test' } }
    end

    before do
      allow(FatZebra::WebHook).to receive(:request).and_return(api_response('New Test hook'))
      web_hook.update(name: 'New Test hook', id: '071-WH-2')
    end

    it 'sends each attribute once with string keys, the new value and no id' do
      expect(FatZebra::WebHook).to have_received(:request)
        .with(:put, anything, { 'name' => 'New Test hook', 'mode' => 'Test' }, {})
    end
  end

end
