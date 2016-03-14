# dockerfiles
Dockerfiles for base images that make creating correct, minimal images for applications easier.

## Images
#### `praekeltfoundation/debian-base`
Provides a basic Debian base image with a few utility scripts for handling `apt-get`, environment variables, and Docker volumes.

#### `praekeltfoundation/python-base`
Provides a basic Python 2 base image built on Debian with the same utility scripts as `debian-base`. Also configures `pip` to not use a cache and to use the Praekelt Foundation Python Package Index.

#### `praekeltfoundation/pypy-base`
Same as the `python-base` image but with [PyPy](http://pypy.org) instead of the standard CPython Python implementation.

### Building the images
```shell
IMAGE_NAME=debian-base # For example
docker build -t ${IMAGE_NAME} -f ${IMAGE_NAME}.dockerfile .
```

## Common Docker problems
### `apt-get` wasn't designed for containers
`apt-get` caches a lot of files such as package indexes and package (.deb) files by default. We want to keep our Docker images as small as possible and most of these cached files are not useful to us. Also, we probably want to run `apt-get update` every time something is installed because we have no guarantee when it was last run. Unlike a regular machine - Docker containers generally won't run `apt-get update` automatically at a regular interval.

Another problem is that it's a pain to remember the correct `apt-get` options to get `apt-get` to install packages quietly, without prompting, and without extra packages that we don't need.

##### Our solution:
Two simple scripts that wrap `apt-get install` and `apt-get purge` to make it easy to run the commands correctly. Simply use [`apt-get-install.sh`](debian-base/scripts/apt-get-install.sh) to install packages and [`apt-get-purge.sh`](debian-base/scripts/apt-get-purge.sh) to remove packages.

### PID 1 and the zombie reaping problem
For a complete explanation of this problem see [this](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/) excellent blog post by Phusion. Suffice to say, many programs expect the system they're running on to have an init system that will manage/clean up child processes but most Docker containers don't have an init system.

##### Our solution:
Using a very very simple init system that reaps orphaned child processes and passes through signals to the main process. We use the (badly named) [`dumb-init`](https://github.com/Yelp/dumb-init) by Yelp.

This program is the default entrypoint on the `debian-base` image so using it should be automatic most of the time - simply specify a `CMD []` in your Dockerfile.

### Shell parent processes
It's quite easy to accidentally get Docker to run your containers with `/bin/sh -c` as the entrypoint. The problem with this is that your process then runs under a shell. i.e. the process with PID == 1 is a shell (`/bin/sh`) - and your process is a child of that process. Shells don't usually pass signals down to their child processes so it becomes difficult to send signals and handle graceful shutdowns of your process. Commands like `docker stop` and `docker kill` are effectively broken. With a shell parent process, `docker stop` will simply time out trying to tell your process to stop and will kill the process.

There is a subtle difference between the two forms of the [Dockerfile `CMD` directive](https://docs.docker.com/engine/reference/builder/#cmd). In the (easiest to write) form, `CMD command arg1`, the command is actually wrapped in `/bin/sh -c`. In the other form, `CMD ["command", "arg1"]`, the command is not wrapped and the entrypoint is used if it is set. **Always prefer the second form.**

Another problem is that if the command is not wrapped in a shell, variables aren't evaluated in the `CMD` instruction because there is no shell to ever resolve the variables' values.

##### Our solution:
* A Bash script that evaluates each part of a command to resolve all the variables' values and then `exec`s the resulting command.
* The images have this script launching `dumb-init` as the default `ENTRYPOINT`.
* **Always using the `CMD ["command", "arg1"]` `CMD` format.**

### Sourcing runtime environment variables
This is a bit of a niche problem-- but sometimes it is useful to provide environment variables at build-time using a separate file rather than by adding a bunch of `ENV` instructions in the Dockerfile. It's impossible to read environment variables using a `RUN` command as each `RUN` command is run in a subshell. One solution is to source the desired file at run-time and then hand over control to the actual process. It's important to do this in a way that doesn't result in a parent shell process.

##### Our solution:
A simple script that sources a file and then exec's a process: [`source-wrapper.sh`](debian-base/scripts/source-wrapper.sh).

### Docker volume owners
This problem will only apply in certain circumstances when using Docker volumes. The problem arises when the owner (user/group) of the volume on the host does not exist in the Docker container. This is very often the case as the volume directory on the host is likely owned by the current user while in the Docker container there is usually only one user - `root`. There are various obscure permissions problems that can occur in this case, particularly with certain build tools.

##### Our solution:
A *hack*. The [`create-volume-user.sh`](debian-base/scripts/create-volume-user.sh) script can create a user and group with UID/GID that match those of the volume owner. This must happen at container runtime as the UID/GID of the volume can't be known before the volume is mounted.
