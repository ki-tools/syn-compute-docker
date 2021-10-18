#!/bin/bash

# Waits for the system apt daily checks to complete.
# This happens the first time the instance is created/started and certain times per day.
while [[ $(ps aux | grep "root" | grep -i "apt") ]]
do
  echo "`date` Waiting for system apt processes to finish..."
  sleep 3
done

# Install packages via apt-get.
# Args: package names
# Example: installAptPackages git r-base other-pkg1 other-pkg2
installAptPackages() {
  for PACKAGE_NAME in "$@"; do
    if ! $(apt -qq list ${PACKAGE_NAME} 2>/dev/null | grep -qE "(installed|upgradeable)"); then
      echo ""
      echo "==> Installing package: ${PACKAGE_NAME}"

      sudo apt-get install -y "${PACKAGE_NAME}"
      INSTALL_STATUS=$?

      if [ ${INSTALL_STATUS} -ne 0 ]; then
        echo "==!> Package install failed. Aborting."
        exit 1
      fi
    fi
  done
}

# Install packages via pip.
# Args: pip args.
# Example: installPipPackage csv-schema
installPipPackage() {
  echo ""
  echo "==> Running: $@"
  if ! python -m pip install "$@"; then
    echo "==!> Package install failed. Aborting."
    exit 1
  fi
}

# Execute a command and exit with status 1 if the command fails.
# Args: command to execute
# Example: execOrExit ls -al
execOrExit() {
  echo ""
  echo "==> Running: $@"
  if ! "$@"; then
    echo "==!> Command Failed, aborting: $@"
    exit 1
  fi
}

echo 'PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc

execOrExit sudo apt-get update
execOrExit sudo apt-get upgrade -y

installAptPackages apt-utils curl git wget awscli vim

# Install pip and radian (nicer R terminal)
installAptPackages python3-venv python3-pip
execOrExit python -m pip install -U pip
installPipPackage -U radian

# Create alias 'r' that runs the radian R terminal
echo 'alias r="radian"' >> ~/.bashrc

# Install python packages
installPipPackage Cython
installPipPackage synapseclient
installPipPackage pyarrow
installPipPackage pandas
installPipPackage plotnine
installPipPackage numpy
installPipPackage pyspark
installPipPackage synapse-downloader
installPipPackage synapse-uploader

# Install Anaconda
installAptPackages libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
execOrExit wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh && bash Anaconda3-2021.05-Linux-x86_64.sh -b && rm Anaconda3-2021.05-Linux-x86_64.sh
echo 'PATH="$PATH:$HOME/anaconda3/bin"' >> ~/.bashrc
