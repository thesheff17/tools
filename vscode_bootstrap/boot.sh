#!/bin/bash
#
# Copyright (c) Dan Sheffner Digital Imaging Software Solutions, INC
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish, dis-
# tribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the fol-
# lowing conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABIL-
# ITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

# this will bootstrap a debian based docker container that vscode uses.

# if see room for improvements make a PR on github.  This is only tested
# on a debian instance since that is the default vscode dev container docker 
# uses. see Dockerfile for more info

SECONDS=0

clear
echo "dockervscode_bootstrap.sh started..."

pythonversion="3.11.1"
# pythonversion="3.10.9"
goversion="go1.19.4"
terraformversion="1.3.6"
arch=`uname -m`

apt_get_install() {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -yq \
        build-essential \
        curl \
        curl \
        g++ \
        gcc \
        git \
        gnupg \
        gnupg2 \
        gpg \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        llvm \
        locate \
        make \
        openjdk-11-jdk \
        procps \
        python3-dev \
        python3-pip \
        software-properties-common \
        tk-dev \
        tmux \
        unzip \
        vim \
        wget \
        wget \
        xz-utils \
        zip \
        zlib1g-dev
}

python_install() {
    # installing python manually
    cpucount=`grep -c processor /proc/cpuinfo`
    
    # check if we are using a beta version
    if grep -q "b" <<< "$pythonversion"; then
        echo "configuring a beta version of python..."
        sub=$(echo $pythonversion | cut -db -f1)
        wget -q https://www.python.org/ftp/python/$sub/Python-$pythonversion.tar.xz
       
    else
        echo "configuring a standard version of python..."
        wget -q https://www.python.org/ftp/python/$pythonversion/Python-$pythonversion.tar.xz
    fi

    tar -xf Python-$pythonversion.tar.xz
    cd Python-$pythonversion

    # why you should use enable optimzations
    # https://bugs.python.org/issue24915
    ./configure --enable-optimizations
    make -j $cpucount
    sudo make install
    # sudo ln -s $HOME/Python-$var/python /usr/local/bin/python-$val
    cd ../
}

golang_install() {
    # install golang
    FILE2=/usr/local/go/bin/go
    if [ ! -f $FILE2 ]
    then
        echo "installing golang..."
        # detects arch for running on M1 macs laptops
        if [ $arch == "aarch64" ]; then
            wget -q https://go.dev/dl/$goversion.linux-arm64.tar.gz
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $goversion.linux-arm64.tar.gz
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        else
            wget -q https://go.dev/dl/$goversion.linux-amd64.tar.gz
            sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $goversion.linux-amd64.tar.gz
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        fi
    else
        echo "golang already installed..."
    fi
}

vim_go_install() {
    # install vim-go plugin
    FILE3=~/.vim/pack/plugins/start/vim-go
    if [ ! -f $FILE3 ]
    then
        echo "installing vim-go plugin..."
        git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
        export PATH=$PATH:/usr/local/go/bin && vim -esN +GoInstallBinaries +q
    else
        echo "vim-go plugin already installed..."
    fi
}

rust_install() {
    # installing rust
    FILE4=~/.cargo/env
    if [ ! -f $FILE4 ]
    then
        curl https://sh.rustup.rs -sSf | sh -s -- -y
    else
        echo "rust already installed..."
    fi
}

nodejs_install() {
    # nodejs
    FILE5=/tmp/nodesource_setup.sh
    if [ ! -f $FILE5 ]
    then
        curl -sL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh
        sudo bash /tmp/nodesource_setup.sh
        sudo apt-get install -y nodejs
        curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        sudo apt-get update && sudo apt-get -y install yarn
    else
        echo "nodejs already looks to be installed..."
    fi
}

ruby_rails_install() {
    # ruby/rvm
    FILE6=~/.rvm/VERSION
    if [ ! -f $FILE6 ]
    then
        curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
        curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
        curl -sSL https://get.rvm.io | bash -s stable --ruby
        curl -sSL https://get.rvm.io | bash -s stable --rails

        # special case to see if root is running this script
        if [[ $EUID -eq 0 ]]; then
            echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc
        else
            echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc
        fi
    else
        echo "ruby/rails already installed..."
    fi
}

terraform_install() {
    FILE7=/usr/bin/terraform
    if [ ! -f $FILE7 ]
    then

        if [ $arch == "aarch64" ]; then
            wget -q https://releases.hashicorp.com/terraform/$terraformversion/terraform_"$terraformversion"_linux_arm64.zip
            unzip terraform_"$terraformversion"_linux_arm64.zip
            sudo mv terraform /usr/bin/terraform
        else
            wget -q https://releases.hashicorp.com/terraform/$terraformversion/terraform_"$terraformversion"_linux_amd64.zip
            unzip terraform_"$terraformversion"_linux_amd64.zip
            sudo mv terraform /usr/bin/terraform
        fi
    else
        echo "terraform binary found skipping install..."
    fi
}

build_index() {
    echo "building search index..."
    sudo updatedb
}

check_versions() {
    echo "node version: "
    node --version
    echo "yarn version: "
    yarn --version
    echo "npm version: "
    npm --version
    echo "python version: "
    python3 --version
    echo "go version: "
    go version
    echo "java version: "
    java --version
    echo "terraform version: "
    terraform --version

    # checking for rails/ruby
    if [[ $EUID -eq 0 ]]; then
        echo "rails version: "
        source /usr/local/rvm/scripts/rvm && rails --version
        echo "ruby version: "
        source /usr/local/rvm/scripts/rvm && ruby --version
    else
        echo "rails version: "
        source $HOME/.rvm/scripts/rvm && rails --version
        echo "ruby version: "
        source $HOME/.rvm/scripts/rvm && ruby --version
    fi
    echo "rust version: "
    $HOME/.cargo/bin/rustc --version
}

apt_get_install
python_install
golang_install
vim_go_install
rust_install
nodejs_install
ruby_rails_install
terraform_install
build_index
check_versions

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "dockervscode_bootstrap.sh completed."