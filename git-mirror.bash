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

UPSTREAM="$1"
REPO_DIR="$2"
: ${INTERVAL:="30s"}

if [ ! -d "${REPO_DIR}" ] ; then
    log "Cloning the upstream repo ${UPSTREAM} as mirror to ${REPO_DIR}"
    git clone --mirror "${UPSTREAM}" "${REPO_DIR}" || die "Failed to clone repository. Fatal error!"
else
    log "Repository directory already exists. No clone performed"
fi

cd "${REPO_DIR}" || die "Failed to switch to the repository directory."

log "Enable git-maintenance for persistent performance"
git maintenance start || die "Failed to enable maintenance for the repository."

while true ; do
    log "Updating the repository"
    git remote update --prune

    log "Sleeping for ${INTERVAL}"
    sleep "${INTERVAL}"
done
