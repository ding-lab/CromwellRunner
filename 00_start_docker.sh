source Project.config.sh

if [ $SYSTEM == "MGI" ]; then

# Launch docker environment at MGI before running cromwell.
# Note that we are using a pre-packaged container.  TODO: update this to 
# the image being used for compute1

    /gscmnt/gc2560/core/env/v1/bin/gsub -m 32

elif [ $SYSTEM == "compute1" ]; then

    >&2 echo Launching docker on compute1

    CMD="bash docker/start_docker.compute1.sh"
    >&2 echo Running: $CMD
    eval $CMD

else 

    >&2 echo Unknown SYSTEM $SYSTEM

fi
