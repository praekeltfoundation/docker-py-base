# docker-py-base
[![Build Status](https://github.com/praekeltfoundation/docker-py-base/actions/workflows/build.yaml/badge.svg)](https://github.com/praekeltfoundation/docker-py-base/actions)

Dockerfiles for base images that make creating correct, minimal images for Python applications easier.

> **NOTE:** The `latest`/shorter form tags now track the latest Python and Debian releases. The shorter/latest tags for these images originally pointed to Debian Jessie and Python 2.7 images. For example, the `latest` tag used to be the Debian Jessie/Python 2.7 image. This has been updated to match the behaviour of the upstream image tags. You should generally use the most specific tag that you need, for example `2.7-stretch`.

## Images
#### `praekeltfoundation/python-base`
[![Docker Pulls](https://flat.badgen.net/docker/pulls/praekeltfoundation/python-base)](https://hub.docker.com/r/praekeltfoundation/python-base/)

Provides Debian--based Python images with some utility scripts, `tini`, and `gosu`. Also configures `pip` to not use a cache and to use the Praekelt.org Python Package Index. For more information about our Package Index, see [`praekeltfoundation/debian-wheel-mirror`](https://github.com/praekeltfoundation/debian-wheel-mirror).

#### `praekeltfoundation/pypy-base`
[![Docker Pulls](https://flat.badgen.net/docker/pulls/praekeltfoundation/pypy-base)](https://hub.docker.com/r/praekeltfoundation/pypy-base/)

Same as the `python-base` image but with [PyPy](http://pypy.org) instead of the standard CPython Python implementation.

### Building the images
Use the `FROM_IMAGE` build argument to adjust the image to build from. For example:

```
> $ docker build -t python-base:3.6 --build-arg FROM_IMAGE=python:3.6-slim .
```

## Common Docker problems
### `apt-get` wasn't designed for containers
`apt-get` caches a lot of files such as package indexes and package (.deb) files by default. We want to keep our Docker images as small as possible and most of these cached files are not useful to us. Also, we probably want to run `apt-get update` every time something is installed because we have no guarantee when it was last run. Unlike a regular machine - Docker containers generally won't run `apt-get update` automatically at a regular interval.

Another problem is that it's a pain to remember the correct `apt-get` options to get `apt-get` to install packages quietly, without prompting, and without extra packages that we don't need.

##### Our solution:
Two simple scripts that wrap `apt-get install` and `apt-get purge` to make it easy to run the commands correctly. Simply use [`apt-get-install.sh`](debian/scripts/apt-get-install.sh) to install packages and [`apt-get-purge.sh`](debian/scripts/apt-get-purge.sh) to remove packages.

### PID 1 and the zombie reaping problem
For a complete explanation of this problem see [this](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/) excellent blog post by Phusion. Suffice to say, many programs expect the system they're running on to have an init system that will manage/clean up child processes but most Docker containers don't have an init system.

##### Our solution:
Using a very very simple init system that reaps orphaned child processes and passes through signals to the main process. We use [`dumb-init`](https://github.com/Yelp/dumb-init) or [`tini`](https://github.com/krallin/tini), depending on which packages are available for the specific operating system. The interfaces for these two programs are very similar and we symlink both to be available as `tini`, `dumb-init`, and `dinit`.

> **Note:** `tini` is built-in to Docker 1.13.0+. It can be enabled by passing `--init` to `dockerd` or `docker run`. Once all our infrastructure moves to a new-enough version of Docker, we may enable that and remove `tini` from these images.

This program is the default entrypoint for all the images, so using it should be automatic most of the time - simply specify a `CMD []` in your Dockerfile.

### Shell parent processes
It's quite easy to accidentally get Docker to run your containers with `/bin/sh -c` as the entrypoint. The problem with this is that your process then runs under a shell. i.e. the process with PID == 1 is a shell (`/bin/sh`) - and your process is a child of that process. Shells don't usually pass signals down to their child processes so it becomes difficult to send signals and handle graceful shutdowns of your process. Commands like `docker stop` and `docker kill` are effectively broken. With a shell parent process, `docker stop` will simply time out trying to tell your process to stop and will kill the process.

There is a subtle difference between the two forms of the [Dockerfile `CMD` directive](https://docs.docker.com/engine/reference/builder/#cmd). In the (easiest to write) form, `CMD command arg1`, the command is actually wrapped in `/bin/sh -c`. In the other form, `CMD ["command", "arg1"]`, the command is not wrapped and the entrypoint is used if it is set. **Always prefer the second form.**

##### Our solution:
* **Always using the `CMD ["command", "arg1"]` `CMD` format.**
* Remember to [`exec`](http://www.grymoire.com/Unix/Sh.html#uh-72) processes launched by shell scripts.

### Changing user at runtime
By default, everything in Docker containers is run as the root user. While containers are relatively isolated from the host machine they run on, Docker doesn't make any guarantees about that isolation from a security perspective. It is considered a best practice to lower privileges within a container. Docker provides a mechanism to change users: the [`USER`](https://docs.docker.com/engine/reference/builder/#/user) Dockerfile command. Setting the `USER` results in all subsequent commands in the Dockerfile to be run under that user. The problem with this is that in practice one generally wants to perform actions that would require root permissions right up until the main container process is launched. For example, you might want to install some more packages, or the entrypoint script for your process might need to create a working directory for your process.

Unfortunately, existing tools like `su` and `sudo` weren't designed for use inside containers and introduce their own problems, similar to those described above with parent shell processes. For more information, read the [`gosu`](https://github.com/tianon/gosu#why) docs.

#### Our solution:
* `su-exec`/`gosu`: We install either [`gosu`](https://github.com/tianon/gosu) or [`su-exec`](https://github.com/ncopa/su-exec), and symlink the one as the other so you should always be able to run both `su-exec` and `gosu` commands. Which one is installed depends on which packages are available on the specific operating system. They have the same interfaces so it should be possible to use them interchangeably.
* Generally you should create a user to run your process under and then `su-exec` to that user in the entrypoint script for the process. For example:

`Dockerfile`:
```dockerfile
# ...
RUN addgroup vumi \
    && adduser -S -G vumi vumi
# ...
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

`docker-entrypoint.sh`:
```shell
#!/usr/local/sbin/tini /bin/sh
# ...

exec su-exec vumi \
    twistd --nodaemon vumi_worker \
    --param1 arg1 \
    --param2 arg2
```

## Older scripts
Some of our common practices for Docker containers have evolved over time and a few of the patterns we've used in the past we're not using much anymore. For posterity, the [`scripts-archive`](scripts-archive) directory contains some scripts that we don't use anymore and aren't built into our images but some people may still find useful.
