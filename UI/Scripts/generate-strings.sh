#!/bin/bash

# Generate L10n strings from Localizable.strings using SwiftGen
# Run from the UI package directory: ./Scripts/generate-strings.sh

cd "$(dirname "$0")/.."
swiftgen

echo "✅ Strings generated successfully"
