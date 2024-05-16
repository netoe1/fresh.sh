#!/bin/bash/

echo "Installing dev dependencies:"
sudo dnf install nodejs
sudo dnf install python3
sudo dnf install g++
sudo dnf install gcc
sudo dnf install postgresql
sudo dnf install openjdk
sudo dnf install code
sudo dnf install curl
sudo dnf install wget
sudo dnf install npm 
sudo dnf install java
sudo dnf install flatpak
sudo dnf install git 
sudo dnf install make 

# Installing nvm

echo "Installing and configuring nvm...."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install stable 
nvm alias default stable


# Configuration for flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo








