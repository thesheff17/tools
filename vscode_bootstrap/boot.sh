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
SECONDS=0

clear
echo "dockervscode_bootstrap.sh started..."

pythonversion=`cat pythonversion.txt`
goversion=`cat goversion.txt`
arch=`uname -m`

# apt-get
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -yq \
    build-essential \
    curl \
    gcc \
    git \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    llvm \
    python3-dev \
    python3-pip \
    tk-dev \
    tmux \
    vim \
    wget \
    xz-utils \
    zlib1g-dev

# this will kinda check if this script already ran
# if you want to run this part remove .pyenv folder
# also remove symlink generated below.
FILE1=/home/vscode/.pyenv/libexec/pyenv
if [ ! -f $FILE1 ]
then
	# cat pyenvbash >> ~/.bashrc
	curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
	# source ~/.bashrc

    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc

	# install python
	export PYENV_ROOT="$HOME/.pyenv" && \
	export PATH="$PYENV_ROOT/bin:$PATH" && \
	eval "$(pyenv init --path)" && \
	eval "$(pyenv init -)" && \
	pyenv install $pythonversion

	sudo ln -s /home/vscode/.pyenv/versions/$pythonversion/bin/python3 /usr/local/bin/$pythonversion
else
	echo "skipping installation .pyenv exists.  delete this and the symlink to run again..."
fi

# install golang
FILE2=/usr/local/go/bin/go
if [ ! -f $FILE2 ]
then
	# detects arch for running on M1 macs laptops
    if [ $arch == "aarch64" ]; then
        wget https://go.dev/dl/$goversion.linux-arm64.tar.gz
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $goversion.linux-arm64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    else
        wget https://go.dev/dl/$goversion.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $goversion.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    fi
else
    echo "golang already installed..."
fi

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "dockervscode_bootstrap.sh completed."