#!/bin/bash

set -e
set -o pipefail

# Function to retry commands
retry_command() {
    local -r cmd="$1"
    local -r max_attempts=3
    local -r sleep_time=5
    
    for attempt in $(seq 1 $max_attempts); do
        echo "Attempt $attempt of $max_attempts: $cmd"
        if eval "$cmd"; then
            return 0
        fi
        echo "Command failed. Retrying in $sleep_time seconds..."
        sleep $sleep_time
    done
    
    echo "Command '$cmd' failed after $max_attempts attempts."
    return 1
}

# Update system packages and install required dependencies
echo "Updating system packages..."
retry_command "sudo apt-get update"
retry_command "sudo apt-get install -y curl jq ca-certificates zip"

# Install Azure CLI
echo "Installing Azure CLI..."
retry_command "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"

# Add Docker's official GPG key and repository
echo "Setting up Docker repository..."
sudo install -m 0755 -d /etc/apt/keyrings
retry_command "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc"
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list and install Docker
retry_command "sudo apt-get update"
retry_command "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"

# Configure Docker to enable containerd snapshotter
echo '{"features": {"containerd-snapshotter": true}}' | sudo tee /etc/docker/daemon.json > /dev/null

# Restart Docker service
sudo systemctl restart docker
sudo systemctl enable docker

# Download GitHub Runner
echo "Downloading GitHub Runner..."
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | cut -c 2-)

# Create a new user for the GitHub Runner
echo "Creating user 'action'..."
sudo useradd -m action -G docker 

# Create runner directory
echo "Creating runner directory..."
RUNNER_DIR="/home/action/actions-runner"
mkdir -p $RUNNER_DIR
sudo chown -R action:action $RUNNER_DIR
cd $RUNNER_DIR

# Download and extract the GitHub Runner package
echo "Downloading GitHub Runner package..."
retry_command "curl -o actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz"

echo "Extracting GitHub Runner package..."
tar xzf actions-runner-linux-x64-$RUNNER_VERSION.tar.gz
sudo chown -R action:action $RUNNER_DIR

# Configure the runner
echo "Configuring GitHub Runner..."
runuser -l action -c "$RUNNER_DIR/config.sh --url https://github.com/P3-Digital-Services/WP10-Image-Factory --token ${runner_token} --labels ubuntuFactoryRunner --name ImageFactoryRunner --runnergroup Default --work $RUNNER_DIR --unattended --runasservice"

# Install the runner as a service
echo "Installing GitHub Runner as a service..."
sudo ./svc.sh install

# Update service to run as 'action' user
echo "Updating service user..."
sudo sed -i 's/User=root/User=action/' /etc/systemd/system/actions.runner.P3-Digital-Services-WP10-Image-Factory.ImageFactoryRunner.service
sudo systemctl daemon-reload

# Start the GitHub Runner service
echo "Starting GitHub Runner service..."
sudo ./svc.sh start

# Install Grype and Syft scanners
install_scanner() {
    local name=$1
    local url=$2
    echo "Installing $name..."
    if curl -sSfL "$url" | sh -s -- -b /usr/local/bin; then
        echo "$name installed successfully"
    else
        echo "Failed to install $name. Please check network connectivity and try again."
        return 1
    fi
}

install_scanner "Grype" "https://raw.githubusercontent.com/anchore/grype/main/install.sh"
install_scanner "Syft" "https://raw.githubusercontent.com/anchore/syft/main/install.sh"

echo "### GitHub Runner installation completed successfully ###"