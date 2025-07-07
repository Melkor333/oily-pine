# Oily Alpine!

Building all alpine packages with oils-for-unix instead of busybox ash or bash.

This should work with either `podman` or `docker`.

## How to build packages

There are 2 ways to build packages:
- Using a `container`
    - Works without a dedicated machine
    - Very easy to set up and hack
    - Sadly for some reason automated builds with `buildrepo` fail with unknown errors like `C compiler can't create executables`
- Using this repo on a dedicated Alpine Linux machine and `rootbld` builds
    - Bigger hassle to set up, needs a VM
    - Not as easy to hack, you can't e.g. easily spawn containers.
    - Documentation is still TODO!

### Using containers

Use the script `./container.sh`.

`./container.sh build` sets up an alpine container with a build user and installs Oils to /bin/sh and /bin/bash.
- It does a "dirty install" of a newer version of Oils. This means the installed oils comes from [install-dirty-oils.sh](./container/install-dirty-oils.sh).
    - if an URL to a tarball (must end in `.tar`) is given, it uses this version
- It sets up a build user, etc. to make sure building packages works

`./container.sh package` runs the container and builds all packages (or a single package if given. e.g. `./container.sh package main/bash`)
- with the following 4 mount points and build packages:
    - ../ -> The package sources (/home/packager/aports)
    - ./abuild -> The gpg key and abuild config is stored (and reused) from here (/home/packager/.abuild)
    - ./packages -> That's where the built packages will go (/home/packager/packages)
    - ./logs -> Logs will be put here (/home/packager/logs)
- If missing, creates GPG keys, see [./setup-key.sh](./setup-key.sh).
- if no package is given, it runs `buildrepo`, see [./package.sh](./package.sh).

`./container.sh hack` start a container to manually build packages, etc.
- Use this to build a single package: `cd ~/aports/main/bash && abuild -r`

`./find-broken.sh` Finds `src` directories of unfinished package builds which are most certainly failed builds. Currently running builds will also be displayed.

### Rootbld

The `rootbld.sh` script expects to be run on an alpine linux vm. This repository must be cloned into the vm.

`rootbld.sh oils URL` takes an URL to an oils tarball and creates an `oils-for-unix.apk` binary package from this binary.
To do that it does:
- download the URL tarball
- extract it
- rename the src folder to match ~/aports/testing/oils-for-unix
- cd to ~/aports/testing/oils-foe-unix
- run `abuild build` to compile the extracted source
- remove preexisting oils-for-unix packages
- run `abuild package rootpkg index` which creates an `apk` of the built binary
Why? a CI tarball looks slightly different to a release tarball (tar /tar.gz and oils-for-unix-WRONGVERSION). The above circumvents that.

`rootbld.sh package [PACKAGE]` uses runs a modified `abuild roorbld` which uses the previously built `oils-for-unix.apk` as part of the rootbld base.

TODO: currently doesn't use abuild-oils! Also untested :)
`rootbld.sh buildrepo` builds a whole repo using `buildrepo`

### abuild-oils and buildrepo-oils

`abuild` has some hardcoded packages it installs into a `rootbld` as a base. `abuild-oils` is a patched version which also installs `oils-for-unix` and `oils-for-binsh` into the chroot.

`buildrepo-oils` just uses `abuild-oils` instead of `abuild`.


## Bash Dependencies

All packages in the `main` repo have been migrated to depend on `cmd:bash` instead of `bash`.
If that's not the case, `abuild` (tries to) install `bash` and thus `/bin/bash` will not be a link to oils anymore.
TODO: Do this for community and testing repos as well.
