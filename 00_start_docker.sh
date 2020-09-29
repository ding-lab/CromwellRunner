# Launch docker environment before running cq or other queries.

# using WUdocker to start image: https://github.com/ding-lab/WUDocker.git
#   * as a result, docker/start_docker.*.sh are deprecated
#   * these are kept for now for reference

# It is expected that cromwell jobs will be launched with bsub rather than parallel

source Project.config.sh

START_DOCKERD="docker/WUDocker"

IMAGE="mwyczalkowski/cromwell-runner"
MEM=4  # should be high for running Cromwell.  If just querying (cq), default is fine

>&2 echo Launching $IMAGE on $SYSTEM
CMD="bash $START_DOCKERD/start_docker.sh -I $IMAGE -M $SYSTEM -m $MEM $@ $VOLUME_MAPPING"
echo Running: $CMD
eval $CMD
