#Using alpine base image
FROM alpine:latest

#Installing jq and setting up the working directory
RUN apk update && apk add jq && rm -rf /var/cache/apk/* && mkdir /app
WORKDIR  /app

# docker build --file=./Dockerfile  -t jq .
# docker run -it jq