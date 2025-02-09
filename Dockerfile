# This should be the lightest image.
# Using 3.10 because: https://github.com/aziascreations/Youtube-Auto-Archiver/issues/1
FROM python:3.10-alpine

LABEL "org.opencontainers.image.source"="https://github.com/SteffenAuer/Youtube-Auto-Archiver"
LABEL "org.opencontainers.image.title"="Youtube Auto Archiver"

# Reading the build arguments.
# * BUID -> Build UID
# * BGID -> Build GID
ARG BUID=1000
ARG BGID=1000

# Installing dependencies.
# * 'g++', 'make' -> Compiling some dependencies.
# * 'libxslt-dev', 'libxml2-dev' -> Compiling some dependencies (ARM only, apparently).
# * 'py3-lxml' -> Pre-compiled module, allows you to ignore compilation errors.
RUN apk update && apk upgrade && \
    apk add --no-cache g++ make py3-lxml ffmpeg libxslt-dev libxml2-dev

# Previously used to compile lxml for streamlink.  (Not used for the moment)
# RUN apk add --no-cache

# Installing required Python packages.
ADD --chown=$BUID:$BGID ./requirements.txt /app/requirements.txt
RUN pip install --upgrade -r /app/requirements.txt

# Removing packages that are no longer needed and were used for compiling streamlink and its dependencies.
# * Some are left however: libgcc, libstdc++, libgomp and gmp
# * Reduces the HDD usage from 198 MiB to 127 MiB for these packages
RUN apk del g++ make

# Copying the app's files to the container
ADD --chown=$BUID:$BGID . /app

# Running the application.
# * Thanks to jdpus for the "-u" flag, it fixes the output (https://stackoverflow.com/a/29745541/4135541)
WORKDIR /app
USER $BUID:$BGID
CMD ["python", "-u", "/app/app.py"]

# Used for debugging.
#CMD ["tail", "-f", "/dev/null"]
