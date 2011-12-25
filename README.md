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

Here's what I'm aiming for:


Daemon:

    pinger start # Starts the pinger daemon
    pinger stop  # Stops the pinger daemon

Domains:

    pinger list          # Lists all domains in pinger's database
    pinger add DOMAIN    # Add a domain to pinger's database
    pinger remove DOMAIN # Remove the domain from pinger's database
    pinger ping DOMAIN   # Test the domain
    pinger show DOMAIN   # Show details for a domain
        


License
-------

Copyright (c) 2011 Spencer Steffen & Citrus, released under the New BSD License All rights reserved.
