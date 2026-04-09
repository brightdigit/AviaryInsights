#!/bin/sh

mise exec -- swift-openapi-generator generate --output-directory Sources/AviaryInsights/Generated --config openapi-generator-config.yaml openapi.yaml
