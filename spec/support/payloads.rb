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

  let(:valid_sca_enrollment_payload) {{
    customer: {
      address_1: '23 Smith Road',
      address_2: 'North Shore',
      city: 'Canberra',
      country: 'AU',
      state: 'NSW',
      email: 'test@test.com',
      first_name: 'James',
      last_name: 'Smith',
      phone_number: '0444555666',
      post_code: '2000',
      passport_number: 'X1234567890',
      passport_country: '036',
      account_changed_at: '20191210',
      account_created_at: '20191210',
      account_password_changed_at: '20191210'
    },
    shipping_address: {
      address_1: '23 Smith Road',
      address_2: 'North Shore',
      city: 'Sydney',
      country: 'AU',
      state: 'NSW',
      email: 'test@test.com',
      first_name: 'James',
      last_name: 'Smith',
      phone_number: '0444555666',
      post_code: '2000',
      method: 'pickup',
      destination_code: '01',
    },
    custom: {
      transaction_mode: 'mobile',
      reference_id: SecureRandom.hex,

      merchant_name: 'TEST',
      merchant_new_customer: true,
      preorder: 1,

      http_accept: 'text/html',
      http_user_agent: 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',

      recurring_end_date: '20201201',
      recurring_frequency: 3,
      recurring_original_purchase_date: '2019120112:00:00'
    },
    items: [
      {
        unit_price: 23.3,
        product_description: 'Widgets',
        product_name: 'Watch',
        quantity: 1,
        product_sku: '9999',
        passenger_first_name: 'John',
        passenger_last_name: 'Smith',
      }
    ],
    airline_data: {
      legs: [
        {
          carrier_code: 'code',
          departure_date: '20221012',
          destination: 'SYD',
          originating_airport_code: 'MEL',
        }
      ],
      number_of_passengers: 2,
      passengers: [
        {
          first_name: 'John',
          last_name: 'Smith',
        },
        {
          first_name: 'Megan',
          last_name: 'Doe',
        }
      ]
    }
  }}

  let(:valid_sca_validation_payload) {{
    authentication_transaction_id: SecureRandom.hex,
    signed_pares: SecureRandom.hex
  }}

  let(:valid_sca_authentication_payload) {{
    card_token: credit_card.token,
    amount: 100,
    currency: 'AUD',
    customer_ip: '111.111.111.111',
    sca: {
      type: 'enrollment',
      merchant_reference_code: SecureRandom.uuid,
    }
  }}

  let(:valid_charge_billing_agreement_payload) {{
    reference: SecureRandom.uuid,
    amount: 1100,
    currency: "AUD",
    customer_ip: '1.2.3.4',
    options: {
      brand_name: "EXAMPLE INC"
    },
    purchases: [{
      description: "Sporting Goods",
      custom_id: "CUST-HighFashions",
      soft_descriptor: "HighFashions",
      amount: {
        item_total: 900,
        shipping: 200
      },
      items: [{
        name: "T-Shirt",
        unit_amount: 900,
        qty: 1,
        category: "PHYSICAL_GOODS"
      }],
      shipping_address: {
        method: "United States Postal Service 1",
        address: {
          first_name: "John",
          last_name: "Doe",
          address_1: "100 Kent Street",
          address_2: "Cafe Lane",
          city: "Sydney",
          state: "NSW",
          postcode: "2000",
          country: "AU"
        }
      }
    }]
  }}

end
