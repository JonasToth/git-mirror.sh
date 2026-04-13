FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        openssh-client \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -r git \
 && useradd -r -g git git

ADD git-mirror.sh /usr/bin/git-mirror

USER git

ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"
ENTRYPOINT ["/usr/bin/git-mirror"]
