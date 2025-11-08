# git-mirror.sh

A dead simple bash script to mirror a repository to a specific directory.
The indended use case it to provide a local cache of a repository in CI environments.
Each run can use `git clone --reference <mounted-path-to-repo>` to reduce network traffic
and improve throughput.

The default interval is 30 seconds and can be controlled with environment variable
`INTERVAL`.

## Example

### Direct Usage

The examples assume, that `git-clone` can access the provided upstream.
My personal experience is, that setting up SSH-Keys properly is the easiest way to have
robust automated `git` access.

```bash
$ # Mirror 'llvm' to the directory '~/software/llvm-project.git'.
$ git-mirror git@github.com:llvm-project/llvm ~/software/llvm-project.git

$ # Perform the update of the 'llvm' repository every 2 minutes.
$ INTERVAL=2m git-mirror github.com:llvm-project/llvm ~/software/llvm-project.git
```

### Containerized Usage

#### Podman

```bash
$ podman pull ghcr.io/jonastoth/git-mirror.sh:latest

$ # Create the target directory for the mirror to allow a minimal directory mount.
$ mkdir ~/software/mirror-llvm-project

$ # Adding the '--user root' option fixes user rights when mounting the repository.
$ # If 'podman' is run as normal user, the effective UID in the container will be
$ # the UID of the user executing the 'podman' process. This is a bit confusing...
$ podman run --rm -it \
    --user root \
    --volume $HOME/software/mirror-llvm-project:/repo:rw,Z \
    --volume $HOME/.ssh:/root/.ssh:ro,Z \
    --env "INTERVAL=1m" \
    ghcr.io/jonastoth/git-mirror.sh:latest \
    git@github.com:llvm/llvm-project /repo
```

#### Docker

```bash
$ docker pull ghcr.io/jonastoth/git-mirror.sh:latest

$ # Create the target directory for the mirror to allow a minimal directory mount.
$ mkdir ~/software/mirror-llvm-project

$ # Executing with the users UID in the container requires the mapping of the '/etc/passwd'
$ # file. Otherwise, 'ssh' fails to access its configuration.
$ docker run --rm -it \
    --user $(id -u):$(id -g) \
    --volume $HOME/software/mirror-llvm-project:/repo:rw \
    --volume /etc/passwd:/etc/passwd:ro \
    --volume $HOME/.ssh:/home/$USERNAME/.ssh:ro \
    --env "INTERVAL=1m" \
    ghcr.io/jonastoth/git-mirror.sh:latest \
    git@github.com:llvm/llvm-project /repo
```

## Installation

```bash
$ # System wide installation
$ sudo install git-mirror.sh /usr/bin/git-mirror

$ # Install only for the current user.
$ install git-mirror.sh ~/.local/bin/git-mirror
```

## Building the Images

```bash
$ podman build -t ghcr.io/jonastoth/git-mirror.sh:latest
$ podman push ghcr.io/jonastoth/git-mirror.sh:latest
```

## References

- [Configuring SSH Access for git](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
