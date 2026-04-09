#!/bin/bash
set -e  # Exit on any error

# More portable way to get script directory
if [ -z "$SRCROOT" ]; then
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    PACKAGE_DIR="${SCRIPT_DIR}/.."
else
    PACKAGE_DIR="${SRCROOT}"
fi

if [ "$LINT_MODE" == "NONE" ]; then
	exit
elif [ "$LINT_MODE" == "STRICT" ]; then
	SWIFTFORMAT_OPTIONS="--strict"
	SWIFTLINT_OPTIONS="--strict"
else
	SWIFTFORMAT_OPTIONS=""
	SWIFTLINT_OPTIONS=""
fi

pushd "$PACKAGE_DIR" || exit 1

mise exec -- swift-openapi-generator generate \
  --output-directory Sources/AviaryInsights/Generated \
  --config openapi-generator-config.yaml openapi.yaml

if [ -z "$CI" ]; then
	bash "$SCRIPT_DIR/header.sh" "$PACKAGE_DIR/Sources"
	bash "$SCRIPT_DIR/header.sh" "$PACKAGE_DIR/Tests"
	mise exec -- swift-format format --in-place --recursive .
	mise exec -- swiftlint --fix
fi

if [ -z "$FORMAT_ONLY" ]; then
    mise exec -- swift-format lint --recursive $SWIFTFORMAT_OPTIONS . || exit 1
    mise exec -- swiftlint lint $SWIFTLINT_OPTIONS || exit 1
fi

popd
