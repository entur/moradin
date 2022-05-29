FROM node:17-alpine3.14

ENV WORKDIR /home/importer
ENV CLOUDSDK_INSTALL_DIR /usr/local/gcloud/
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

## Install build toolchain, install node deps and compile native add-ons
RUN apk add --no-cache python3 make g++ curl bash

RUN curl -sSL https://sdk.cloud.google.com | bash

# change working dir
WORKDIR ${WORKDIR}

COPY import.sh ${WORKDIR}
COPY package.json ${WORKDIR}
RUN npm install

RUN chown -R node:node ${WORKDIR}

USER node

# TODO: Override pelias.json, Hvordan ?
ENTRYPOINT ["/home/importer/import.sh"]
