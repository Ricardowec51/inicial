#!/bin/bash
#  by Ricardo Wagner
# Update the apt package index
echo "Updating the apt package index..."
sudo apt update

# Install useful commands
echo "Installing useful commands: neofetch, bpytop, glances..."
sudo apt install -y neofetch bpytop glances

# Check if a kernel update is available
if [[ $(sudo apt list --upgradable 2>/dev/null | grep linux-image | wc -l) -gt 0 ]]; then
  echo "A kernel update is available. Updating the kernel..."
  sudo apt install -y --only-upgrade linux-image-generic
  echo "Kernel update complete. Please reboot your system."
  exit 0
else
  echo "No kernel updates available."
fi

# Check if Docker is already installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Proceeding with installation..."

    # Install packages to allow apt to use a repository over HTTPS
    echo "Installing packages to allow apt to use a repository over HTTPS..."
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add the official GPG key for Docker
    echo "Adding the official GPG key for Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add the Docker repository to APT sources
    echo "Adding the Docker repository to APT sources..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the apt package index again
    echo "Updating the apt package index again..."
    sudo apt update

    # Check if latest Docker version is available
    if [[ $(sudo apt-cache policy docker-ce | grep 'Candidate:' | awk '{print $2}') == *:* ]]; then
        DOCKER_VERSION=$(sudo apt-cache policy docker-ce | grep 'Candidate:' | awk '{print $2}')
        echo "Latest Docker version available: $DOCKER_VERSION"

        # Install Docker
        echo "Installing Docker..."
        sudo apt install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io

        # Add the current user to the docker group to run Docker commands without sudo
        echo "Adding the current user to the docker group..."
        sudo usermod -aG docker $USER

        # Install docker-compose
        echo "Installing docker-compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        # Print Docker version
        echo "Docker installed successfully."
        docker --version
        docker-compose --version

    else
        echo "Unable to find the latest version of Docker. Installation aborted."
    fi
else
    echo "Docker is already installed. Skipping Docker installation."
fi
#install other usefull utilities (For me)
sudo apt install bpytop glances 
