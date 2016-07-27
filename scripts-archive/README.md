# scripts-archive

## Common Docker problems
### Sourcing runtime environment variables
This is a bit of a niche problem-- but sometimes it is useful to provide environment variables at build-time using a separate file rather than by adding a bunch of `ENV` instructions in the Dockerfile. It's impossible to read environment variables using a `RUN` command as each `RUN` command is run in a subshell. One solution is to source the desired file at run-time and then hand over control to the actual process. It's important to do this in a way that doesn't result in a parent shell process.

##### Our solution:
A simple script that sources a file and then exec's a process: [`source-wrapper.sh`](common/source-wrapper.sh).

### Docker volume owners
This problem will only apply in certain circumstances when using Docker volumes. The problem arises when the owner (user/group) of the volume on the host does not exist in the Docker container. This is very often the case as the volume directory on the host is likely owned by the current user while in the Docker container there is usually only one user - `root`. There are various obscure permissions problems that can occur in this case, particularly with certain build tools.

##### Our solution:
A *hack*. The [`create-volume-user.sh`](debian/create-volume-user.sh) script can create a user and group with UID/GID that match those of the volume owner. This must happen at container runtime as the UID/GID of the volume can't be known before the volume is mounted.
