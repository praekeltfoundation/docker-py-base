#!/usr/bin/env bash
set -eo pipefail

DEFAULT_OS=debian
IMAGE_NAMESPACE=praekeltfoundation

self="$(basename "$0")"
usage_error() {
	cat <<-EOU
		error: $1
		usage: $self <base_os> <variant> <version>...
		   ie: $self debian python 2.7
	EOU
	exit 1
}

base_os="$1"; shift || usage_error 'missing base_os'
variant="$1"; shift || usage_error 'missing variant'
version="$1"; shift || usage_error 'missing version'

tag="${IMAGE_NAMESPACE}/${variant}-base:${version}"
if [[ "$base_os" != "$DEFAULT_OS" ]]; then
	tag="${tag}-${$base_os}"
fi

# Pull the existing image for caching
docker pull "$tag" || true

# Do the build
pushd "$base_os"
docker build --pull --cache-from "$tag" -t "$tag" -f "${variant}/${version}/Dockerfile" .
popd

# Save the image
docker save -o "${base_os}-${variant}-${version}.tar" "$tag"
