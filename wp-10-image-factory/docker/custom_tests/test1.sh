#!/bin/bash

## EXAMPLE OF CUSTOM TEST SCRIPT

# Check if DOCKER_IMAGE is set
if [ -z "$DOCKER_IMAGE" ]; then
  echo "Error: DOCKER_IMAGE environment variable is not set."
  exit 1
fi


# Function to test the Docker image
test_image() {
  echo "Testing Docker image: $DOCKER_IMAGE"

  # Generate Software Bill of Materials (SBOM) using Syft
  echo "Generating SBOM..."
  syft "$DOCKER_IMAGE" -o json > sbom.json

  # Check for vulnerabilities using Grype
  echo "Scanning for vulnerabilities..."
  grype "$DOCKER_IMAGE" --fail-on high

  # Optionally, output the SBOM
  echo "SBOM generated: sbom.json"
}

# Execute the test function
test_image