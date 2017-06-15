require 'rspec'

shared_context 'payloads' do

  let(:valid_purchase_payload) {{
    amount:      10000,
    card_holder: 'Matthew Savage',
    card_number: '5123456789012346',
    card_expiry: DateTime.new(2030, 2, 3).strftime('%m/%Y'),
    cvv:         123,
    reference:   SecureRandom.hex,
    customer_ip: '1.2.3.4'
  }}

  let(:valid_credit_card_payload) {{
    card_holder: 'Matthew Savage',
    card_number: '5123456789012346',
    card_expiry: DateTime.new(2030, 2, 3).strftime('%m/%Y'),
    cvv:         123
  }}

  let(:customer_valid_payload) {{
    first_name: 'Harrold',
    last_name:  'Humphries',
    reference:  SecureRandom.hex,
    email:      'hhump@test.com',
    ip_address: '180.200.33.181',
    card: {
        card_holder: 'Harrold Humphries Senior',
        card_number: '5123456789012346',
        expiry_date: '05/2023',
        cvv:         '123'
    },
    address: {
        address:  '1 Harriet Road',
        city:     'Kooliablin',
        state:    'NSW',
        postcode: '2222',
        country:  'Australia'
    }
  }}

end
