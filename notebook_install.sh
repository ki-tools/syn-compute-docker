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

# Install random dependencies for R and R packages etc.
installAptPackages gnupg2 gnupg libfreetype6-dev dirmngr apt-transport-https ca-certificates software-properties-common libxml2-dev libcurl4-openssl-dev libssl-dev cmake

# Install two helper packages we need
execOrExit sudo apt-get install --no-install-recommends software-properties-common dirmngr

# Add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
execOrExit sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# Upgrade R
execOrExit rm -rf ~/R
installAptPackages r-base
installAptPackages build-essential
execOrExit sudo Rscript -e 'update.packages(ask=FALSE, checkBuilt=TRUE)'

# Install pip and radian (nicer R terminal)
installAptPackages python3-venv python3-pip
execOrExit python -m pip install -U pip
installPipPackage -U radian

# Create alias 'r' that runs the radian R terminal
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
echo 'alias r="radian"' >> ~/.bashrc

# Re-Install packages for R 4.x -- TODO: This might not be working completely.
execOrExit sudo Rscript -e 'install.packages("codetools", repos = "https://cloud.r-project.org")'
execOrExit sudo Rscript -e 'install.packages("colorspace", repos = "https://cloud.r-project.org")'
execOrExit sudo Rscript -e 'install.packages("munsell", repos = "https://cloud.r-project.org")'
execOrExit sudo Rscript -e 'install.packages("scales", repos = "https://cloud.r-project.org")'
execOrExit sudo Rscript -e 'install.packages("Rcpp", repos = "https://cloud.r-project.org")'
execOrExit sudo Rscript -e 'install.packages("pkgload", repos = "https://cloud.r-project.org")'
execOrExit sudo Rscript -e 'install.packages("ggplot2", repos = "https://cloud.r-project.org")'

# Install tidyverses
execOrExit sudo Rscript -e 'install.packages("tidyverse", repos = "https://cloud.r-project.org")'
execOrExit sudo Rscript -e 'Sys.setenv(ARROW_S3 ="ON"); install.packages("arrow", repos = "https://cloud.r-project.org")'

R --version

# Install synapser R package
execOrExit sudo Rscript -e 'install.packages("synapser", repos=c("http://ran.synapse.org", "http://cran.fhcrc.org"))'

# Install reticulate
execOrExit sudo Rscript -e 'install.packages("reticulate", repos = "https://cloud.r-project.org")'

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
