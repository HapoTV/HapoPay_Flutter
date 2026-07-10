#!/bin/bash
for file in .github/workflows/*.yml; do
    echo "Fixing $file"
    # Remove any existing flutter-version or channel lines in the Setup Flutter step
    sed -i '/flutter-version:/d' "$file"
    sed -i '/channel:/d' "$file"
    # Add the channel line after Setup Flutter
    sed -i '/name: Setup Flutter/,/with:/ s/with:/with:\n        channel: '\''stable'\''\n        cache: true/' "$file"
done
