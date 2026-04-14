#!/bin/bash

set -euo pipefail

# Write an error message to stderr and exit the script with code 1.
die() {
    >&2 echo "[!] $*"
    exit 1
}
# Write a message to stderr.
log() {
    >&2 echo "[*] $*"
}
# Seconds since Epoch.
secondsSinceEpoch() {
    date '+%s'
}
elapsedSeconds() {
    local timestampBefore="$1"
    local timestampAfter="$2"
    expr "${timestampAfter}" - "${timestampBefore}"
}
repositoryCleanup() {
    log "Remove unreachable objects"
    git gc --prune=now

    log "Checking for repository errors"
    git fsck

    log "Optimizing to single .pack file"
    git repack -Ad

    log "Repository cleanup complete!"
}

UPSTREAM="$1"
REPO_DIR="$2"
: ${INTERVAL:="30s"}
# Seconds inbetween cleanups.
# 86400 := 1 day
: ${CLEANUP_INTERVAL:="86400"}

log "Running as:"
log "  - id: $(id -u)"
log "  - group: $(id -g)"
log "  - \$HOME: ${HOME}"

log "Performing mirror updates every ${INTERVAL}"

if [ -d "${REPO_DIR}" ] ; then
    log "Repository directory already exists."
else
    log "Repository directory not existing yet. Creating it."
    mkdir -p "${REPO_DIR}" || die "Failed to create directory for repository."
fi

log "Switching to repository directory."
cd "${REPO_DIR}" || die "Failed to switch to the repository directory."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null ; then
    log "Directory is not a git-repo. Cleaning directory content."
    rm -rf *

    log "Cloning the upstream repo ${UPSTREAM} as mirror to ${REPO_DIR}"
    git clone --mirror "${UPSTREAM}" "." || die "Failed to clone repository. Fatal error!"
else
    log "Directory already contains a git repository. No clone performed"
    repositoryCleanup
fi

lastCleanup=$(secondsSinceEpoch)
while true ; do
    lastSync=$(secondsSinceEpoch)
    log "Updating the repository"
    git remote update --prune

    if [ $(elapsedSeconds ${lastCleanup} ${lastSync}) -ge "${CLEANUP_INTERVAL}" ] ; then
        log "Performing repository cleanup."
        repositoryCleanup
        lastCleanup=$(secondsSinceEpoch)
    else
        log "Sleeping for ${INTERVAL}"
        sleep "${INTERVAL}"
    fi
done
