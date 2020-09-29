# Start local instance of cromwell server (rather than relying on default MGI production server)
# This gets around problems with database queries circa summer 2019
# With this server running, database queries are to http://localhost:8000
# Only one server should be running at once.  It should be run after `gsub` (after 0_start_docker.sh)
# and should exit when the docker container exits

source Project.config.sh
bash cromwell-server/spawn_cromwell_server.sh $SYSTEM

#echo Please run the following:
#echo
#echo export PATH="\$PATH:./src"

