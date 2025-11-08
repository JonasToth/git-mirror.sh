FROM alpine:latest

RUN apk add \
        git \
        openssh
ADD git-mirror.sh /usr/bin/git-mirror

ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
ENTRYPOINT ["/usr/bin/git-mirror"]
