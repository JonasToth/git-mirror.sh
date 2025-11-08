#!/bin/sh

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
fi

while true ; do
    log "Updating the repository"
    git remote update --prune

    log "Sleeping for ${INTERVAL}"
    sleep "${INTERVAL}"
done
