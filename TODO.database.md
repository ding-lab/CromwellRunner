Implement new generation database
* MySQL server runnign on Mammoth
* simple file-based database for testing


# MySQL

Erik Storrs:
okay so got a start on the documentation and there is now a cromwell server and
database running on mammoth. Barebones documentation for setting up or
restarting the server is here https://github.com/estorrs/cromwell-server

## Cromwell version

Erik currently using Cromwell v78

# File-based database

Work by MAW described here:
/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/CWL-dev/SomaticSV-dev/SomaticSV.database/README.database.md

FileDB is a good solution for one-off runs, like those in CWL testing scripts (cromwell-simple).
For production runs recommend MySQL


# Background reading

https://cromwell.readthedocs.io/en/stable/Configuring/ (Cromwell server on MySQL Database)

https://docs.docker.com/compose/

