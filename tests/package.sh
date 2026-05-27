#!/usr/bin/env bash
# Validate that package tarballs can be extracted directly into /srv.

set -e
set -o pipefail
set -u

package="${1:-}"

if [[ -z "${package}" ]]; then
  echo "Usage: $0 <package.tgz>" >&2
  exit 1
fi

if [[ ! -f "${package}" ]]; then
  echo "Package not found: ${package}" >&2
  exit 1
fi

entries="$(mktemp)"
manifest_paths="$(mktemp)"
trap 'rm -f "${entries}" "${manifest_paths}"' EXIT

tar tzf "${package}" | sort > "${entries}"

if grep -qE '^(\./)?dist/' "${entries}"; then
  echo "Package contains an unintended dist/ prefix." >&2
  exit 1
fi

if ! grep -qxE '(\./)?MANIFEST' "${entries}"; then
  echo "Package does not contain MANIFEST at the archive root." >&2
  exit 1
fi

{ tar xOf "${package}" ./MANIFEST 2>/dev/null \
  || tar xOf "${package}" MANIFEST 2>/dev/null; } \
  | awk '{ print $2 }' \
  | sed 's#^/srv/#./#' \
  | sort > "${manifest_paths}"

while IFS= read -r expected_entry; do
  if [[ -z "${expected_entry}" ]]; then
    continue
  fi

  if ! grep -qxF "${expected_entry}" "${entries}"; then
    echo "MANIFEST path has no matching archive entry: ${expected_entry}" >&2
    exit 1
  fi
done < "${manifest_paths}"

echo "Package layout matches MANIFEST paths."
