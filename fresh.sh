#!/bin/bash
# MIT MODIFIED LICENSE

# Copyright (c) 2026 Ely Torres Neto - Vertex Project - elynetobr@gmail.com

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# 1. RETENTION OF NOTICE: The above copyright notice and this permission 
# notice shall be included in all copies or substantial portions of the 
# Software.

# 2. ATTRIBUTION OF AUTHORSHIP: In the event of any modification to the 
# Software that remains open-source, the modified version must prominently 
# include a reference to the original authors/creators and their contact 
# information as provided in the original copyright notice.

# 3. PATENT RESTRICTION: This license does not grant any rights to file for, 
# or enforce, any patents based on the Software, its algorithms, or its 
# documentation. Any attempt to patent the Software or its derivative works 
# shall result in the immediate termination of this license for the 
# infringing party.

# 4. DISCLAIMER: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY 
# KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN 
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
# USE OR OTHER DEALINGS IN THE SOFTWARE.

#echo "-----------------------------"
# echo "Installing dev dependencies:"
# sudo apt install nodejs
# sudo apt install python3
# sudo apt install g++
# sudo apt install gcc
# sudo apt install postgresql
# sudo apt install openjdk
# sudo apt install code
# sudo apt install curl
# sudo apt install wget
# sudo apt install npm 
# sudo apt install java
# sudo apt install ffunction latpak
# sudo apt install git 
# sudo apt install make 


# Create an empty array for dependencies.
declare -a DEPENDENCIES


# Receive a parameter and trim string.
function trim() {
    echo "$1" | xargs
}
# generic helper: return 0 if command is available, 1 otherwise

function command_exists() {
    # usage: command_exists <name>
    # shellcheck disable=SC2145
    command -v "$1" >/dev/null 2>&1
}


function is_app_installed() {
    local pkg="$1"

    # 1. Validação de entrada: Se o nome estiver vazio, retorne erro (1)
    [[ -z "$pkg" ]] && return 1

    # 2. Verificação via dpkg-query (O método mais seguro para APT)
    # Procuramos especificamente pelo estado "install ok installed"
    # O ^ e $ no grep garantem que a linha seja exatamente essa, sem variações.
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "^install ok installed$"; then
        return 0
    fi

    # 3. Verificação via command -v (Para binários fora do APT)
    # Isso cobre nvm, docker (se instalado via binário), scripts no /usr/local/bin, etc.
    # Usamos o 'command -v' pois ele é um builtin do shell, mais rápido que o 'which'.
    if command -v "$pkg" >/dev/null 2>&1; then
        return 0
    fi

    # 4. Se chegou aqui, o pacote/comando realmente não foi encontrado
    return 1
}

function is_package_installed() {
    local pkg="$1"
    
    # Se o nome estiver vazio, retorna erro
    [[ -z "$pkg" ]] && return 1

    # O dpkg-query é a fonte da verdade para o APT.
    # Se ele não retornar "install ok installed", o pacote precisa de atenção.
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "^install ok installed$"; then
        return 0 # Está instalado corretamente
    fi

    return 1 # Não está instalado ou está quebrado
}

function install_nvm(){  
  if ! command_exists nvm; then
      echo "fresh.sh: nvm doesn't exists in PATH – needs install /config"
      echo "fresh.sh: Installing and configuring nvm...."
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
      export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
      nvm install stable 
      nvm alias default stable
  else
      echo "fresh.sh nvm is already installed!"
  fi
}

# Load dependencies by file.cfg
function load_dependencies_cfg(){
  echo "fresh.sh: Preparing to load dependencies file..."

  local cfg_path="$1"            

  if [[ -z "$cfg_path" ]]; then
    echo "fresh.sh: no path provided" >&2
    return 1
  fi

  if [[ ! -f "$cfg_path" ]]; then # -f verifica se é um arquivo regular
    echo "fresh.sh: $cfg_path does not exist or is not a file!" >&2
    return 1
  fi

  if [[ ! -s "$cfg_path" ]]; then
     echo "fresh.sh: $cfg_path is empty" >&2
     return 0        
  fi

  DEPENDENCIES=()

  # O '|| [[ -n "$line" ]]' garante que a última linha seja lida mesmo sem \n no final
  while IFS= read -r line || [[ -n "$line" ]]; do

    # 1. Remove caracteres \r (estilo Windows)
    line="${line//$'\r'/}"

    # 2. Trim (remover espaços no início e fim)
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # 3. Ignora linhas vazias ou comentários
    [[ -z "$line" || "$line" == \#* ]] && continue

    DEPENDENCIES+=("$line")
  done < "$cfg_path"

  echo "fresh.sh: Loaded ${#DEPENDENCIES[@]} dependencies."
}

function setting_flatpak_config(){  
  if app_installed flatpak; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
}

function install_by_apt() {
  # 'local' evita que a variável 'aux' vaze para fora da função
  local aux=""
  
  echo 'fresh.sh: now, we gonna install dependencies by apt. We gonna need your sudo password.'

  for i in "${DEPENDENCIES[@]}"; do
    if ! is_package_installed "$i"; then
       aux+="$i "
    fi
  done
  
  # Limpa o espaço extra no final
  aux=$(trim "$aux")

  echo "$aux"

  if [ -n "$aux" ]; then
    echo "fresh.sh: Installing: $aux"
    sudo apt update && sudo apt install -y $aux
  else
    echo "fresh.sh: all dependencies are already installed!"
  fi
}

function main(){
  load_dependencies_cfg ./dependencies.cfg
  install_by_apt 
  echo "fresh.sh: exiting..."
}

main