# Rocky Linux Toolbox creation

[Toolbox](https://github.com/containers/toolbox) is a tool for Linux operating systems, which allows the use of containerized command line environments. It is built on top of [Podman](https://podman.io) and other standard container technologies from [OCI](https://opencontainers.org).

This is particularly useful on OSTree based operating systems. The intention of these systems is to discourage installation of software on the host, and instead install software as (or in) containers — they mostly don't even have package managers like DNF or YUM. This makes it difficult to set up a development environment or install tools for debugging in the usual way.

Toolbox solves this problem by providing a fully mutable container within which one can install their favourite development and debugging tools, editors and SDKs. For example, it's possible to do `dnf install ansible` without affecting the base operating system.

However, this tool doesn't require using an OSTree based system. It works equally well on any Rocky Linux installation, and that's a useful way keep the day to day use OS clean or to incrementally adopt containerization.

The toolbox environment is based on an [OCI](https://www.opencontainers.org) image. In Rocky Linux this is the `rocky-toolbox` image. This image is used to create a toolbox container that seamlessly integrates with the rest of the operating system by providing access to the user's home directory, the Wayland and X11 sockets, networking (including Avahi), removable devices (like USB sticks), systemd journal, SSH agent, D-Bus, ulimits, /dev and the udev database, etc.

## Attribution

This image is heavily inspired by Fedora's [fedora-toolbox](https://src.fedoraproject.org/container/fedora-toolbox) image creation repo.

## Installtion

On a Rocky Linux host system, to use toolbox it is needed to install the application first, `dnf install toolbox`. Most OSTree based operating systems will ship toolbox installed by default.

## Usage

### Toolbox environment creation

```bash
[user@hostname ~] toolbox create
Created container: rocky-toolbox-9
Enter with: toolbox enter
```

As this has been run on a Rocky Linux system, it will by default create a `rocky-toolbox-<major-version-id>` container.

### Enter the toolbox

```bash
[user@hostname ~] toolbox enter
⬢[user@toolbox ~]$
```

### Remove a toolbox container

First, make sure the toolbox container is not running anymore:

```bash
[user@hostname ~] toolbox list
IMAGE ID        IMAGE NAME                          CREATED
215122d241c2    quay.io/rockylinux/rocky-toolbox:9  1 minute ago

CONTAINER ID    CONTAINERNAME   CREATED         STATUS  IMAGE NAME
24e4c5535369    rocky-toolbox-9 1 minute ago    running quay.io/rockylinux/rocky-toolbox:9
```

If the toolbox container is still running stop it with the following command:

```bash
[user@hostname ~] podman stop rocky-toolbox-9
rocky-toolbox-9
```

Finally you can remove the toolbox:

```bash
[user@hostname ~] toolbox rm rocky-toolbox-9
```

## Distro support

By default, Toolbox creates the container using an [OCI](https://www.opencontainers.org) image called `<ID>-toolbox:<VERSION-ID>`, where `<ID>` and `<VERSION-ID>` are taken from the host's /usr/lib/os-release. For example, the default image on a Rocky Linux 9 host would be rocky-toolbox:9.

This default can be overridden by the `--image` option in `toolbox create`, but operating system distributors should provide an adequately configured default image to ensure a smooth user experience.

## Image requirements

Toolbox customizes newly created containers in a certain way. This requires certain tools and paths to be present and have certain characteristics inside the OCI image.

Tools: `getent(1) id(1) ln(1) mkdir(1)`: for hosts where `/home` is a symbolic link to `/var/home passwd(1) readlink(1) rm(1) rmdir(1)`: for hosts where `/home` is a symbolic link to `/var/home sleep(1) test(1) touch(1) unlink(1) useradd(8) usermod(8)`

Paths: `/etc/host.conf`: optional, if present not a bind mount `/etc/hosts`: optional, if present not a bind mount `/etc/krb5.conf.d`: directory, not a bind mount `/etc/localtime`: optional, if present not a bind mount `/etc/machine-id`: optional, not a bind mount `/etc/resolv.conf`: optional, if present not a bind mount * `/etc/timezone`: optional, if present not a bind mount.

Toolbox enables `sudo(8)` access inside containers. The following is necessary for that to work:

- The image should have `sudo(8)` enabled for users belonging to either the `sudo` or `wheel` groups, and the group itself should exist. File an [issue](https://github.com/containers/toolbox/issues/new) if you really need support for a different group. However, it's preferable to keep this list as short as possible.
- The image should allow empty passwords for `sudo(8)`. This can be achieved by either adding the `nullok` option to the `PAM(8)` configuration, or by add the `NOPASSWD` tag to the `sudoers(5)` configuration.

Since Toolbox only works with OCI images that fulfill certain requirements, it will refuse images that aren't tagged with the `com.github.containers.toolbox="true"` label. This label is meant to be used by the maintainer of the image to indicate that they have read this document and tested that the image works with Toolbox. You can use the following snippet in a Dockerfile for this:

```text
LABEL com.github.containers.toolbox="true"
```
