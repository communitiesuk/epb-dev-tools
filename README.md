# EPB Dev Tools

The Energy Performance of Buildings Register service consists of several 
distinct applications.

* authentication server
* epb api
* epb frontend

These dev tools give us a stable environment where all the applications are
preconfigured to just work.

## Up and Running

**Requirements**

* docker
* docker-compose
* git
* bash 4 or greater (only if using installation scripts)

### Scripted Installation

The scripted installation was tested on macOS. For other OSs you may want to run
through the manual installation instructions.

1. Create a new directory `MHCLG` to store the dev tools
2. Clone this repository into the `MHCLG` directory so it is located at 
    `MHCLG/epb-dev-tools`
3. From the directory `MHCLG/epb-dev-tools` run the installation script
    `make install`

This script will ask for sudo access as part of the installation, this is needed
to create the needed entries in `/etc/hosts`.

### Manual Installation

Instructions to manually install epb dev tools can be found 
[here](./MANUAL_INSTALL.md).
