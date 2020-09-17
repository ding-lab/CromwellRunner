# Start local instance of cromwell server (rather than relying on default MGI production server)
# This gets around problems with database queries circa summer 2019
# With this server running, database queries are to http://localhost:8000
# Only one server should be running at once.  It should be run after `gsub` (after 0_start_docker.sh)
# and should exit when the docker container exits

# Usage: spawn_cromwell_server.sh SERVER 
# where SERVER is MGI or compute1

if [ "$#" -ne 1 ]; then
    >&2 echo Error: Wrong number of arguments
    exit
fi

if [ $1 == "MGI" ]; then
    CONFIG="cromwell-server/server-cromwell-config.MGI.dat"
elif [ $1 == "compute1" ]; then
    CONFIG="cromwell-server/server-cromwell-config.compute1.dat"
else
    >&2 echo ERROR: Unknown server $1
    exit 1
fi


CROMWELL="/usr/local/cromwell/cromwell-47.jar"

echo Starting local instance of cromwell server
/usr/bin/java -Dconfig.file=$CONFIG -jar $CROMWELL server >/dev/null & 

