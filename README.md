# docker-base
Dockerfiles for base images that make creating correct, minimal images for applications easier.

> **NOTE:** The tags for these images have changed recently. The `praekeltfoundation/python3-base` tag is now defunct. Use the `praekeltfoundation/python-base:3` tag rather. Also, the `:debian` tags are no longer being updated and will be removed. Debian is the default OS for all images that don't include "alpine" in the tag.

## Images
#### `praekeltfoundation/debian-base`/`alpine-base`
Provides Debian and Alpine Linux base images with a few utility scripts and `dumb-init`.

#### `praekeltfoundation/python-base`
Provides Debian- and Alpine Linux-based Python images with the same utility scripts and `dumb-init` setup as the `base` image. Also configures `pip` to not use a cache and to use the Praekelt.org Python Package Index. For more information about our Package Index, see [`praekeltfoundation/debian-wheel-mirror`](https://github.com/praekeltfoundation/debian-wheel-mirror).

#### `praekeltfoundation/pypy-base`
Same as the `python-base` image but with [PyPy](http://pypy.org) instead of the standard CPython Python implementation.

#### Tags
Debian is the default operating system and `:latest` tags will point to the Debian variants of images. Alpine variants are tagged with `:alpine`.

### Building the images
Images are built in the context of their OS directories. So you can run something like this to build, for example, the Alpine Python 2.7 image:

```
> $ docker build -t python-base:2.7-alpine -f alpine/python/2.7/Dockerfile alpine
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
Using a very very simple init system that reaps orphaned child processes and passes through signals to the main process. We use the (badly named) [`dumb-init`](https://github.com/Yelp/dumb-init) by Yelp.

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
* `su-exec`: We install [`su-exec`](https://github.com/ncopa/su-exec) on the Alpine Linux images which has an identical interface to the better-known [`gosu`](https://github.com/tianon/gosu) but is a much smaller binary and available in the Alpine package archives. On Debian we install `gosu` and symlink it to be available as `su-exec`.
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
#!/usr/bin/dumb-init /bin/sh
# ...

exec su-exec vumi \
    twistd --nodaemon vumi_worker \
    --param1 arg1 \
    --param2 arg2
```

### Python package dependencies
Installing the correct runtime native dependencies for Python packages is not always straightforward. For instance, a package like [`Pillow`](https://pypi.python.org/pypi/Pillow) has dependencies on a number of C libraries for working with images, such as [`libjpeg`](http://libjpeg.sourceforge.net) or [`libwebp`](https://chromium.googlesource.com/webm/libwebp). It's not always clear which libraries are required.

#### Our solution:
We build binary distributions of Python packages that we commonly use and host them in a PyPi repository. For more information, see [this repo](https://github.com/praekeltfoundation/debian-wheel-mirror). On our Alpine Linux images, we've added a script ([`install-py-pkg-deps.sh`](alpine/scripts/install-py-pkg-deps.sh)) that scans Python's site-packages directories for linked libraries and then installs the packages that provide those libraries.

## Older scripts
Some of our common practices for Docker containers have evolved over time and a few of the patterns we've used in the past we're not using much anymore. For posterity, the [`scripts-archive`](scripts-archive) directory contains some scripts that we don't use anymore and aren't built into our images but some people may still find useful.
