Ruby API Library for Fat Zebra
==============================

A Ruby client for the [Fat Zebra](https://www.fatzebra.com) Online Payment Gateway

- [Latest releases](https://github.com/fatzebra/Ruby-Library/releases)
- [Published Gem versions](https://rubygems.org/gems/fat_zebra)

Installing
----------

    gem install fat_zebra

Or in a Rails App (or similar, with Bundler), in your Gemfile:

    gem "fat_zebra"

Usage
-----

```ruby
require 'fat_zebra'

# Configuration only needs to be done once, usually in your rails initializers
FatZebra.configure do |config|
  config.username = 'TEST'
  config.token    = 'TEST'
end

purchase = FatZebra::Purchase.create(
  amount:      10000,
  card_holder: 'Bill Simpson',
  card_number: '5123456789012346',
  card_expiry: '05/2023',
  cvv:         '123',
  reference:   'ORDER-23',
  customer_ip: '203.99.87.4'
)

if purchase.successful?
  puts "Transaction ID: #{purchase.id}"
else
  abort "Error in transaction: #{purchase.errors}"
end
```

Documentation
-------------

Full API reference can be found at http://docs.fatzebra.com

Support
-------
If you have any issue with the Fat Zebra Ruby Client please contact us at support@fatzebra.com and we will be more then happy to help out. Alternatively you may raise an issue in github.

Pull Requests
-------------
If you would like to contribute to the plugin please fork the project, make your changes within a feature branch and then submit a pull request. All pull requests will be reviewed as soon as possible and integrated into the main branch if deemed suitable.
