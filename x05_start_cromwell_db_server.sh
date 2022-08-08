# Use this only when running local server / MGI mode

# Start local instance of cromwell server (rather than relying on default MGI production server)
# This gets around problems with database queries circa summer 2019
# With this server running, database queries are to http://localhost:8000
# Only one server should be running at once.  It should be run after `gsub` (after 0_start_docker.sh)
# and should exit when the docker container exits

source Project.config.sh

CMD="bash src/spawn_cromwell_server.sh $@ $CONFIG_SERVER_FILE"
>&2 echo Running $CMD
eval $CMD

