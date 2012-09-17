Ruby API Library for Fat Zebra
==============================

Release 1.1.2 for API version 1.0

A Ruby client for the [Fat Zebra](https://www.fatzebra.com.au) Online Payment Gateway (for Australian Merchants)

Dependencies
------------

 * Ruby (tested on 1.8.7, 1.9.2, 1.9.3)
 * Rest Client
 * JSON

 [![Build Status](https://secure.travis-ci.org/fatzebra/Ruby-Library.png?branch=master)](http://travis-ci.org/fatzebra/Ruby-Library)

Installing
----------

    gem install fat_zebra

Or in a Rails App (or similar, with Bundler), in your Gemfile:

    gem "fat_zebra"

Usage
-----

```ruby
require 'fat_zebra'

gateway = FatZebra::Gateway.new("TEST", "TEST", "gateway.sandbox.fatzebra.com.au") # You can ommit the last parameter - by default it will use the Live Gateway

card_data = {
	card_number: "5123456789012346",
	card_holder: "Bill Simpson",
	card_expiry: "05/2013",
	ccv: "123"
}
response = gateway.purchase(10000, card_data, "ORDER-23", "203.99.87.4")

if response.successful? && response.result.successful
	puts "Transaction ID: #{response.result.id}"
else
	abort "Error in transaction: #{response.error_messages}"
end
```

Documentation
-------------

Full API reference can be found at http://docs.fatzebra.com.au

Support
-------
If you have any issue with the Fat Zebra Ruby Client please contact us at support@fatzebra.com.au and we will be more then happy to help out. Alternatively you may raise an issue in github.

Pull Requests
-------------
If you would like to contribute to the plugin please fork the project, make your changes within a feature branch and then submit a pull request. All pull requests will be reviewed as soon as possible and integrated into the main branch if deemed suitable.