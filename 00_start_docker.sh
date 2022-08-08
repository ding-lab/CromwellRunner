# Launch docker environment before running cq or other queries.

# using WUdocker to start image: https://github.com/ding-lab/WUDocker.git
#   * as a result, docker/start_docker.*.sh are deprecated
#   * these are kept for now for reference

# It is expected that cromwell jobs will be launched with bsub rather than parallel

source Project.config.sh

START_DOCKERD="docker/WUDocker"

IMAGE="mwyczalkowski/cromwell-runner:v78"  # mammoth server
# IMAGE="mwyczalkowski/cromwell-runner"  # MGI server
MEM=4  
ARG="-q dinglab-interactive -r"
GROUP="-G compute-dinglab"

# Common error - CWL directory does not exist
if [ -z $CWL_ROOT_H ]; then
    >&2 echo ERROR: CWL root directory not defined \(does $CWL_ROOT_H_LOC exist?\)
    exit 1
fi
if [ ! -d $CWL_ROOT_H ]; then
    >&2 echo ERROR: CWL root directory does not exist: $CWL_ROOT_H
    exit 1
fi

>&2 echo Launching $IMAGE on $SYSTEM
CMD="bash $START_DOCKERD/start_docker.sh $ARG -g \"$GROUP\" -I $IMAGE -M $SYSTEM -m $MEM $@ $VOLUME_MAPPING"
echo Running: $CMD
eval $CMD
