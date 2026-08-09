#!/usr/bin/env bash

set -euo pipefail

image_root="${1:-assets/images}"
quality="${2:-82}"

if [[ ! -d "$image_root" ]]; then
  echo "Image directory not found: $image_root" >&2
  exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
  echo "ImageMagick 'magick' is required but not installed." >&2
  exit 1
fi

compressed=0
skipped=0

while IFS= read -r -d '' image; do
  case "${image##*.}" in
    jpg|jpeg|png|webp)
      tmp_file="$(mktemp "${TMPDIR:-/tmp}/image-compress.XXXXXX.${image##*.}")"

      case "${image##*.}" in
        jpg|jpeg)
          magick "$image" -resize 2400x2400\> -strip -interlace Plane -quality "$quality" "$tmp_file"
          ;;
        png)
          magick "$image" -strip -colors 256 -define png:compression-level=9 "$tmp_file"
          ;;
        webp)
          magick "$image" -strip -quality "$quality" "$tmp_file"
          ;;
      esac

      original_size="$(stat -f '%z' "$image")"
      new_size="$(stat -f '%z' "$tmp_file")"

      if (( new_size < original_size )); then
        mv "$tmp_file" "$image"
        printf 'compressed %s: %s -> %s bytes\n' "$image" "$original_size" "$new_size"
        compressed=$((compressed + 1))
      else
        rm -f "$tmp_file"
        skipped=$((skipped + 1))
      fi
      ;;
    *)
      skipped=$((skipped + 1))
      ;;
  esac
done < <(find "$image_root" -type f -print0)

echo "Done. Compressed $compressed file(s), skipped $skipped file(s)."