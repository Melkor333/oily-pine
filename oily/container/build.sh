#!/bin/sh
# Generate key or reuse key
set -e

source "$HOME/.abuild/abuild.conf" || true
echo $HOME
    
# generate a key if not existent
if [ -z "$PACKAGER_PRIVKEY" ]; then
    echo "generating new key"
    abuild-keygen -na --install
else
    echo "using $PACKAGER_PRIVKEY"
    doas cp "$PACKAGER_PRIVKEY".pub /etc/apk/keys
fi

buildrepo $@ main
buildrepo $@ community
buildrepo $@ testing
