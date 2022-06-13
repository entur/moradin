FROM node:16-alpine3.14

ENV WORKDIR /home/moradin
ENV CLOUDSDK_INSTALL_DIR /usr/local/gcloud/
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

## Install build toolchain, install node deps and compile native add-ons
RUN apk add --no-cache python3 make g++ curl bash

RUN curl -sSL https://sdk.cloud.google.com | bash

# change working dir
WORKDIR ${WORKDIR}

COPY package.json ${WORKDIR}
RUN npm install

# Setup pelias configuration
COPY pelias.json ${WORKDIR}
ENV PELIAS_CONFIG ${WORKDIR}/pelias.json

COPY moradin.sh ${WORKDIR}

RUN chown -R node:node ${WORKDIR}

USER node

ENTRYPOINT ["/home/moradin/moradin.sh"]
