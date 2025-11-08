# git-mirror.bash

A dead simple bash script to mirror a repository to a specific directory.
The indended use case it to provide a local cache of a repository in CI environments.
Each run can use `git clone --reference <mounted-path-to-repo>` to reduce network traffic
and improve throughput.

## Example

The examples assume, that `git-clone` can access the provided upstream.
My personal experience is, that setting up SSH-Keys properly is the easiest way to have
robust automated `git` access.

```bash
$ # Mirror 'llvm' to the directory '~/software'
$ git-mirror git@github.com:llvm-project/llvm ~/software/llvm-project.git

$ # Perform the update of the 'llvm' repository every 2 minutes.
$ INTERVAL=2m git-mirror github.com:llvm-project/llvm ~/software/llvm-project.git
```

## Installation

```bash
$ # System-Wide Installation
$ sudo install git-mirror.bash /usr/bin

$ # Install only for the current user.
$ install git-mirror.bash ~/.local/bin
```

## References

- [Configuring SSH Access for git](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
