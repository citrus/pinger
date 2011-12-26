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


Usage
-----

Here's what I'm aiming for in the CLI:

    pinger list          # Lists all uris in pinger's database
    pinger add URI    # Add a uri to pinger's database
    pinger remove URI # Remove the uri from pinger's database
    pinger ping URI   # Test the uri
    pinger show URI   # Show details for a uri
        

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
