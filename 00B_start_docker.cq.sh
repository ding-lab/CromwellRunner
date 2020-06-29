# Launch docker environment at MGI before running cq or other queries.
# do not use this for cromwell jobs because less memory

# using WUdocker to start image: https://github.com/ding-lab/WUDocker.git
#   * as a result, docker/start_docker.*.sh are deprecated
#   * these are kept for now for reference
# 
# In the future, start runs within a non-interactive job instead, like done in step 25 here:
#    https://github.com/ding-lab/importGDC.CPTAC3.git
#  the reason for this is that compute1 has a 24-hour limit on interactive jobs
#

source Project.config.sh

START_DOCKERD="docker/WUDocker"

IMAGE="mwyczalkowski/cromwell-runner"
MEM=4  # should be high for running Cromwell.  If just querying (cq), default is fine

>&2 echo Launching $IMAGE on $SYSTEM
CMD="bash $START_DOCKERD/start_docker.sh -I $IMAGE -M $SYSTEM -m $MEM $@ $VOLUME_MAPPING"
echo Running: $CMD
eval $CMD
