FROM broadinstitute/cromwell:78-38cd360
MAINTAINER Matthew A. Wyczalkowski <m.wyczalkowski@wustl.edu>

LABEL \
    description="Packages necessary to run cromwell v78 and CromwellRunner on LSF, and a few utility tools"

#    gettext-base \
#    apt-utils \

RUN apt-get update -y && apt-get install -y \
    curl \
    git \
    jq \
    libnss-sss \
    parallel \
    vim \
    wget

ENV LC_ALL="C"

ENTRYPOINT ["/bin/sh", "-c"]
