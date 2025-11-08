FROM alpine:latest

RUN apk add \
        git \
        openssh
ADD git-mirror.sh /usr/bin/git-mirror

RUN addgroup -S mirrorgroup \
 && adduser -S mirroruser -G mirrorgroup
USER mirroruser

ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
ENTRYPOINT ["/usr/bin/git-mirror"]
