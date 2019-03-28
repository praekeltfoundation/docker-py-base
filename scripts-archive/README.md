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

### `CMD` instructions don't evaluate shell variables
When using the `CMD` directive properly in its JSON array format (`CMD ["arg1", "arg2"]`), `$` variables aren't evaluated in the `CMD` instruction because there is no shell to ever resolve the variables' values.

#### Our solution:
A Bash script ([`eval-args.sh`](common/eval-args.sh)) that can be used to get shell-like behaviour. It evaluates each part of a command to resolve all the variables' values and then `exec`s the resulting command.

### Python package dependencies
Installing the correct runtime native dependencies for Python packages is not always straightforward. For instance, a package like [`Pillow`](https://pypi.python.org/pypi/Pillow) has dependencies on a number of C libraries for working with images, such as [`libjpeg`](http://libjpeg.sourceforge.net) or [`libwebp`](https://chromium.googlesource.com/webm/libwebp). It's not always clear which libraries are required.

#### Our solution:
We build binary distributions of Python packages that we commonly use and host them in a PyPi repository. For more information, see [this repo](https://github.com/praekeltfoundation/debian-wheel-mirror). On our Alpine Linux images, we've added a script ([`install-py-pkg-deps.sh`](alpine/scripts/install-py-pkg-deps.sh)) that scans Python's site-packages directories for linked libraries and then installs the packages that provide those libraries.
