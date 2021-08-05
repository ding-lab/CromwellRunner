Start local instance of cromwell server (rather than relying on default MGI production server)
This gets around problems with database queries circa summer 2019
With this server running, database queries are to http://localhost:8000
Only one server can run at once and should exit when the docker container exits

Note these configuration file definitions are independent of those passed to the `cromwell run` call,
which are in ../dat/cromwell-config-db.dat


