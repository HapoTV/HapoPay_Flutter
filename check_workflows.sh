#!/bin/bash
echo "=== Checking GitHub Workflows ==="
for file in .github/workflows/*.yml; do
    echo "=== $file ==="
    grep "flutter-version" $file || echo "No flutter-version found"
    grep "sdk:" pubspec.yaml || echo "No SDK constraint found"
    echo ""
done
