#!/bin/bash/

echo "Installing dev dependencies:"
sudo apt install nodejs
sudo apt install python3
sudo apt install g++
sudo apt install gcc
sudo apt install postgresql
sudo apt install openjdk
sudo apt install code
sudo apt install curl
sudo apt install wget
sudo apt install npm 
sudo apt install java
sudo apt install flatpak
sudo apt install git 
sudo apt install make 

# Installing nvm

echo "Installing and configuring nvm...."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install stable 
nvm alias default stable


# Configuration for flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo








