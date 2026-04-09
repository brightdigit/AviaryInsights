#!/bin/bash
set -e

# Adds license headers to Swift source files in the given directory,
# derived from the LICENSE file at the repository root.
# Usage: header.sh <directory>

DIRECTORY="$1"

if [[ -z "$DIRECTORY" || ! -d "$DIRECTORY" ]]; then
  echo "Usage: header.sh <directory>"
  exit 1
fi

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
PACKAGE_DIR="${SCRIPT_DIR}/.."
LICENSE_FILE="$PACKAGE_DIR/LICENSE"

if [[ ! -f "$LICENSE_FILE" ]]; then
  echo "Error: LICENSE file not found at $LICENSE_FILE"
  exit 1
fi

# Build the commented license block from the LICENSE file
build_license_header() {
  while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      echo "//"
    else
      echo "//  $line"
    fi
  done < "$LICENSE_FILE"
}

add_header() {
  local file="$1"
  local filename
  filename=$(basename "$file")
  local tmp
  tmp=$(mktemp)

  {
    echo "//"
    echo "//  $filename"
    echo "//  AviaryInsights"
    echo "//"
    build_license_header
    echo "//"
    echo ""
  } > "$tmp"

  cat "$file" >> "$tmp"
  mv "$tmp" "$file"
  echo "Added header: $file"
}

has_header() {
  local file="$1"
  head -1 "$file" | grep -q "^//"
}

while IFS= read -r -d '' file; do
  if ! has_header "$file"; then
    add_header "$file"
  fi
done < <(find "$DIRECTORY" -name "*.swift" -print0)
