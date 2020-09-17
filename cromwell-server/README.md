Start local instance of cromwell server (rather than relying on default MGI production server)
This gets around problems with database queries circa summer 2019
With this server running, database queries are to http://localhost:8000
Only one server can run at once and should exit when the docker container exits

