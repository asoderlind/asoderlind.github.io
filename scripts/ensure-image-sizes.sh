#!/usr/bin/env bash

set -euo pipefail

max_bytes="${1:-500000}"
image_root="${2:-assets/images}"

if [[ ! -d "$image_root" ]]; then
  echo "Image directory not found: $image_root" >&2
  exit 1
fi

violations="$({ find "$image_root" -type f -exec stat -f '%z %N' {} + | awk -v max_bytes="$max_bytes" '$1 > max_bytes { print }'; } )"

if [[ -n "$violations" ]]; then
  echo "Images over ${max_bytes} bytes:"
  echo "$violations"
  exit 1
fi

echo "All images in $image_root are at or below ${max_bytes} bytes."