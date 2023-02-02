#!/usr/bin/env bash
#
# Copyright 2023 The MathWorks Inc.

# Exit on any failure, treat unset substitution variables as errors
set -euo pipefail

LOCAL_USER=ubuntu

# Create MATLAB Home directory
mkdir -p /home/${LOCAL_USER}/Documents/MATLAB/

# Configure MATLAB_ROOT directory
sudo mkdir -p "${MATLAB_ROOT}"
sudo chmod -R 755 "${MATLAB_ROOT}"

# Install and setup mpm.
# https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md
sudo apt-get -qq install \
  unzip \
  wget \
  ca-certificates
sudo wget --no-verbose https://www.mathworks.com/mpm/glnxa64/mpm
sudo chmod +x mpm

# Run mpm to install MATLAB and other toolboxes in the RELEASE variable
# into the target location. The mpm installation is deleted afterwards.
sudo ./mpm install \
  --doc \
  --release="${RELEASE}" \
  --destination="${MATLAB_ROOT}" \
  --products "${PRODUCTS}"
sudo rm -f mpm /tmp/mathworks_root.log

# Enable MHLM licensing default
sudo mkdir -p "${MATLAB_ROOT}/licenses"
sudo chmod 777 "${MATLAB_ROOT}/licenses"
cp /var/tmp/config/matlab/license_info.xml "${MATLAB_ROOT}/licenses/"

# Add symlink to MATLAB
sudo ln -s "${MATLAB_ROOT}/bin/matlab" /usr/local/bin

# Set keyboard settings to windows flavor for any new user.
sudo mkdir -p "/etc/skel/.matlab/${RELEASE}"
sudo cp /var/tmp/config/matlab/matlab.prf  "/etc/skel/.matlab/${RELEASE}/"

# Set keyboard settings to windows flavor for ubuntu user.
sudo mkdir -p "/home/${LOCAL_USER}/.matlab/${RELEASE}"
sudo cp /var/tmp/config/matlab/matlab.prf "/home/${LOCAL_USER}/.matlab/${RELEASE}/"

# Enable DDUX collection by default for the VM
cd "${MATLAB_ROOT}/bin/glnxa64"
sudo ./ddux_settings -s -c

# Config MHLM Client setting
sudo cp /var/tmp/config/matlab/mhlmvars.sh /etc/profile.d/

# Config DDUX context tag setting
sudo cp /var/tmp/config/matlab/mw_context_tag.sh /etc/profile.d/

# Copy license file to root of the image
sudo cp /var/tmp/config/matlab/thirdpartylicenses.txt /
