# Oily Alpine!

Building all alpine packages with oils-for-unix instead of busybox ash or bash.

This should work with either `podman` or `docker`.

*Warning: For now `--usermode=keep-id` is not configured in the scripts, so the container might change the permissions of local files!*

## How to build packages

There are 2 ways to build packages:
- Using a Container
    - Works without a dedicated machine
    - Very easy to set up and hack
    - Sadly for some reason automated builds with `buildrepo` fail with unknown errors like `C compiler can't create executables`
- Using this repo on a dedicated Alpine Linux machine and `rootbld` builds
    - Bigger hassle to set up, needs a VM
    - Not as easy to hack, you can't e.g. easily spawn containers.
    - Documentation is still TODO!

### Using containers

`./build-container.sh` sets up an alpine container with a build user and installs Oils to /bin/sh and /bin/bash.
- It does a "dirty install" of a newer version of Oils. This means the installed oils comes from [install-dirty-oils.sh](./container/install-dirty-oils.sh).
- It sets up a build user, etc. to make sure building packages works

`./build-packages.sh` runs the container and builds all packages
- with the following 4 mount points and build packages:
    - ../ -> The package sources (/home/packager/aports)
    - ./abuild -> The gpg key and abuild config is stored (and reused) from here (/home/packager/.abuild)
    - ./packages -> That's where the built packages will go (/home/packager/packages)
    - ./logs -> Logs will be put here (/home/packager/logs)
- If missing, creates GPG keys, see [./setup-key.sh](./setup-key.sh).
- runs `buildrepo`, see [./package.sh](./package.sh).

`./hacking.sh` start a container to manually build packages, etc.
- Use this to build a single package: `cd ~/aports/main/bash && abuild -r`

`./find-broken.sh` Finds `src` directories of unfinished package builds which are most certainly failed builds. Currently running builds will also be displayed.

## Bash Dependencies

All packages in the `main` repo have been migrated to depend on `cmd:bash` instead of `bash`.
If that's not the case, `abuild` (tries to) install `bash` and thus `/bin/bash` will not be a link to oils anymore.
TODO: Do this for community and testing repos as well.
