# EPB Dev Tools

The Energy Performance of Buildings Register service consists of several
distinct applications.

* authentication server
* epb api
* epb frontend

These dev tools give us a stable environment where all the applications are
preconfigured to just work.

## Up and Running

### Scripted Installation

**Requirements**

* docker
* docker-compose
* git
* bash 4 or greater (only if using installation scripts)

The scripted installation was tested on macOS. For other OSs you may want to run
through the manual installation instructions.

1. Create a new directory `MHCLG` to store the dev tools
2. Clone this repository into the `MHCLG` directory so it is located at
    `MHCLG/epb-dev-tools`
3. From the directory `MHCLG/epb-dev-tools` run the installation script
    `make install`

This script will ask for sudo access as part of the installation, this is needed
to create the needed entries in `/etc/hosts`.

### Portable Vagrant Installation

**Requirements**

* vagrant
* vagrant hostsupdater (`vagrant plugin install vagrant-hostsupdater`)
* virtualbox

To run the whole infrastructure in a vagrant environment just run the following:

```shell script
$ vagrant up
# ... wait for the installation to finish
$ vagrant reload
```

### Manual Installation

Although unsupported, instructions to manually install epb dev tools can be
found [here](./MANUAL_INSTALL.md).

### Running the service

Assuming all the installation steps succeeded, you can now start the EPB
register service.

```shell script
$ epb start
```

## Ongoing operation

### When the service or dev tools gets updated

When you want to ensure that your local copy of the service is up to date, you
can run the following from the `MHCLG/epb-dev-tools` folder.

```shell script
$ git pull # will ensure that the epb-dev-tools repo is up to date
$ make install # will ensure that the docker compose file is up to date
```

### Where do services sit?

There are three services that make up the Energy Performance of Buildings
Register

* The register api - found at http://epb-register-api
* The register's authentication service - found at http://epb-register-api/auth
* The register's frontend service - found at http://find-energy-certificate.epb-frontend and http://getting-new-energy-certificate.epb-frontend

### Make File

The `make migrate` command migrates a database for a particular application.
If you get an error saying that a database table is missing for a particular application
then running this command should regenerate the database & its tables for you.

If you encounter this warning when trying to run the command

`Must give an application   EPB Devtools Help`

then please use this alternative syntax:

` make migrate APP=<particular_application>`

Eg: make migrate APP=epb-register-api
