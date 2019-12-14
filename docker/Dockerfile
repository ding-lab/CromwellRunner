FROM ubuntu:xenial
MAINTAINER Matthew A. Wyczalkowski <m.wyczalkowski@wustl.edu>
# Based on John Garza's https://github.com/johnegarza/docker-cromwell/blob/master/Dockerfile

LABEL \
    description="Packages necessary to run cromwell and CromwellRunner on LSF, and a few utility tools"

RUN apt-get update -y && apt-get install -y \
    apt-utils \
    curl \
    default-jdk \
    git \
    jq \
    libnss-sss \
    parallel \
    vim

# python-pip \
# RUN pip install --upgrade pip
# RUN pip install pyyaml
# RUN pip install unidecode
# RUN pip install 'setuptools>=18.5'
# RUN pip install cwltool
# RUN pip install 'ruamel.yaml==0.14.2'

