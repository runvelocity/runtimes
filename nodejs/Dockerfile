FROM  docker:dind

WORKDIR /runtime

RUN apk add make s3cmd curl aws-cli nodejs npm

COPY package*.json .

RUN npm install

COPY . .

WORKDIR /builder

COPY scripts scripts

RUN chmod +x /builder/scripts/build-nodejs.sh

