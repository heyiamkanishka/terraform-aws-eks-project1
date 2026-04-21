#!/bin/bash

# 1. Update system and add Jenkins repo
sudo dnf update -y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf upgrade -y

# 2. Install Java 21 (CRITICAL: Jenkins 2.555.1+ requires Java 21)
sudo dnf install java-21-amazon-corretto -y

# 3. Install and Start Jenkins
sudo dnf install jenkins -y
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 4. Install Git
sudo dnf install git -y

# 5. Install Terraform
sudo dnf install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf install terraform -y

# 6. Install kubectl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# 7. Add Swap Space (Prevents t3.small from freezing during EKS builds)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# 8. Output the Initial Admin Password to the logs
echo "--------------------------------------------------------"
echo "JENKINS INITIAL ADMIN PASSWORD:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "--------------------------------------------------------"