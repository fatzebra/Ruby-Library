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

  let(:valid_sca_authenticate_payload) {{
    card_token: credit_card.token,
    sca: {
      enabled: true,
      amount: 100,
      currency: 'AUD',
      df_reference_id: SecureRandom.hex(10),
      mobile_phone: '1234567890',
      email: 'dev@fatzebra.com.au',
      transaction_mode: 'mobile',
      transaction_type: 'C',
      order_number: SecureRandom.hex(10),
      billing: {
        address1: 'SOME ADDRESS',
        city: 'Sydney',
        country: 'AUS',
        first_name: 'John',
        last_name: 'Smith',
        postal_code: '2000',
        state: 'NSW'
      },
      shipping: {
        address1: 'SOME ADDRESS',
        state: 'NSW',
        city: 'Sydney',
        country: 'AUS',
        address2: 'SOME ADDRESS',
        address3: 'SOME ADDRESS',
        postal_code: '2000',
      },
      extra: {
        billing_phone: '1234567890',
        work_phone: '1234567890',
        billing_address2: 'SOME ADDRESS',
        billing_address3: 'SOME ADDRESS',
        authentication_indicator: '01',
        product_code: 'PHY'
      },
      recurring: {
        installment: 2,
        purchase_date: DateTime.now.next_year.strftime('%Y%m%d%H%M%S'),
        recurring_end: DateTime.now.next_year.strftime('%Y%m%d'),
        recurring_frequency: 31
      }
    }
  }}

end
