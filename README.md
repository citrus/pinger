Pinger
======


### .. isn't ready yet.. move along!


Pinger will be a command line tool for monitoring the health of your websites.


Goals
-----

* Simplicity
* Minimal dependencies
* Email notifications of service interuptions
* Multiple DB adapters


Future Goals
------------

* Simple & sexy web interface with charts/graphs


Configuration
-------------

Pinger needs to be setup before doing its job. By default, pinger will look for your config file at `~/.pinger.yml`. You can customize your config path by setting PINGER_CONFIG in your environment.

Here's the available options and their defaults:
    
    :database_url                     => "sqlite://pinger.db",
    :email_to                         => "pinger.alert@example.com",
    :email_from                       => "pinger@example.com",
    :delivery_method                  => :sendmail,
    :delivery_method_options          => {},
    :allowed_response_time_difference => 2
    

You'll probably at least want to overwrite `database_url` and `email_to` in your yml file:

    # ~/.pinger.yml
    database_url: postgres://pinger:pinger@localhost/pinger
    email_to: your-email@your-host.com
    

We're using [mail](https://github.com/mikel/mail) for email delivery. Here's a [link to the available delivery methods](https://github.com/mikel/mail/tree/master/lib/mail/network/delivery_methods).


Usage
-----

Here's the run down:

    pinger help       # Shows pinger's usage
    pinger stats      # Shows stats for pings and uris
    pinger batch      # Runs a ping test for all uris in pinger's database
    pinger list       # Lists all uris in pinger's database
    pinger add URI    # Add a uri to pinger's database
    pinger remove URI # Remove the uri from pinger's database
    pinger ping URI   # Test the uri
    pinger show URI   # Show details for a uri


Add your URIs to pinger's database then tie pinger into your crontab with something like this:

    */15 * * * * /path/to/bin/ruby /path/to/bin/pinger batch >> path/to/pinger.log 



Testing
-------

Testing is done with minitest. Run tests with:

    bundle exec rake
  
  
Sqlite is used by default, but you can test against other database adapters by setting PINGER_TEST_DB like so:

    # postgres
    PINGER_TEST_DB=postgres://root:@localhost/pinger bundle exec rake
    
    # mysql
    PINGER_TEST_DB=mysql2://root:@localhost/pinger bundle exec rake


Make sure you create the appropriate databases before running the tests.


License
-------

Copyright (c) 2011 Spencer Steffen & Citrus, released under the New BSD License All rights reserved.
