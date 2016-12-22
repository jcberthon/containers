#!/bin/bash

if [[ -x /usr/lib/unbound/package-helper ]]; then
  /usr/lib/unbound/package-helper chroot_setup
  /usr/lib/unbound/package-helper root_trust_anchor_update
fi

/usr/sbin/unbound "$@"
