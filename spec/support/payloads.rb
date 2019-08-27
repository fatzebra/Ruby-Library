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

  let(:valid_3ds_authorise_payload) {{
    card_number: '5123456789012346',
    card_expiry: DateTime.now.next_year.strftime('%m/%Y'),
    threeds: {
      enabled: true,
      amount: 100,
      billing_address1: 'SOME ADDRESS',
      billing_city: 'Sydney',
      billing_country_code: '036', # Australia
      billing_first_name: 'John',
      billing_last_name: 'Smith',
      billing_postal_code: '2000',
      billing_state: 'NSW',
      currency_code: '036',
      df_reference_id: SecureRandom.hex(10),
      mobile_phone: '1234567890',
      email: 'dev@fatzebra.com.au',
      transaction_mode: 'mobile',
      transaction_type: 'C',
      order_number: SecureRandom.hex(10),

      shipping_address1: 'SOME ADDRESS',
      shipping_state: 'NSW',
      shipping_city: 'Sydney',
      shipping_country_code: '036',
      shipping_address2: 'SOME ADDRESS',
      shipping_address3: 'SOME ADDRESS',
      shipping_postal_code: '2000',
      billing_phone: '1234567890',
      work_phone: '1234567890',
      billing_address2: 'SOME ADDRESS',
      billing_address3: 'SOME ADDRESS',
      authentication_indicator: '01',
      product_code: 'PHY',

      installment: 2,
      purchase_date: DateTime.now.next_year.strftime('%Y%m%d%H%M%S'),
      recurring_end: DateTime.now.next_year.strftime('%Y%m%d'),
      recurring_frequency: 31
    }
  }}

end
