#!/bin/bash


usage() {
  echo "Usage: $0 -v <jenkins_version>"
  exit 1
}


while getopts ":v:" opt; do
  case $opt in
    v)
      JENKINS_VERSION=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done


if [ -z "$JENKINS_VERSION" ]; then
  echo "Error: Jenkins version not specified."
  usage
fi


if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  echo "Unsupported operating system. Exiting."
  exit 1
fi


install_jenkins_debian() {
  echo "Installing Jenkins $JENKINS_VERSION on Debian-based system..."
  sudo apt update
  sudo apt install -y openjdk-11-jdk curl gnupg

  
  curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee "/usr/share/keyrings/jenkins-keyring.asc" > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

  
  sudo apt update
  sudo apt install -y "jenkins=$JENKINS_VERSION"
}


install_jenkins_redhat() {
  echo "Installing Jenkins $JENKINS_VERSION on Red Hat-based system..."
  sudo yum install -y java-11-openjdk-devel curl

  
  sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

  
  sudo yum install -y "jenkins-$JENKINS_VERSION"
}


case $OS in
  ubuntu|debian)
    install_jenkins_debian
    ;;
  centos|rhel|fedora)
    install_jenkins_redhat
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

# Start and enable Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins


sudo systemctl status jenkins --no-pager

echo "Jenkins $JENKINS_VERSION installation completed successfully."
