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

# pythonversion="3.9.13 3.10.5 3.11.0b4 pypy3.9-7.3.9"
pythonversion="3.9.13"
goversion="go1.18.4"
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
    openjdk-11-jdk \
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

# all of a sudden pyenv SSL cert start failing.
# FILE1=/home/vscode/.pyenv/libexec/pyenv
# if [ ! -f $FILE1 ]
# then
#     echo "installing latest python version with pyenv..."
# 	# cat pyenvbash >> ~/.bashrc
# 	curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
# 	# source ~/.bashrc

#     echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
#     echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
#     echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
#     echo 'eval "$(pyenv init -)"' >> ~/.bashrc

#     for val in $pythonversion; do
#         # install python
#         export PYENV_ROOT="$HOME/.pyenv" && \
#         export PATH="$PYENV_ROOT/bin:$PATH" && \
#         eval "$(pyenv init --path)" && \
#         eval "$(pyenv init -)" && \
#         pyenv install $val

#         sudo ln -s /home/vscode/.pyenv/versions/$val/bin/python3 /usr/local/bin/python-$val
#     done
# else
# 	echo "skipping installation .pyenv exists.  delete this and the symlink to run again..."
# fi

cpucount=`grep -c processor /proc/cpuinfo`
for val in $pythonversion; do
    wget -q https://www.python.org/ftp/python/$val/Python-$val.tar.xz
    tar -xf Python-$val.tar.xz
    cd Python-$val

    # why you should use enable optimzations
    # https://bugs.python.org/issue24915
    ./configure --enable-optimizations
    make -j $cpucount
    make install
    cd ../
done

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

# installing rust 
FILE4=~/.cargo/env
if [ ! -f $FILE4 ]
then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
else
    echo "rust already installed..."
fi

# nodejs
FILE5=/tmp/nodesource_setup.sh
if [ ! -f $FILE5 ]
then
    curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
    sudo bash /tmp/nodesource_setup.sh
else
    echo "nodejs already looks to be installed..."
fi

# ruby/rvm
FILE6=~/.rvm/VERSION
if [ ! -f $FILE6 ]
then
    curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
    curl -sSL https://get.rvm.io | bash -s stable --ruby
    curl -sSL https://get.rvm.io | bash -s stable --rails
    echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc
else
    echo "ruby/rails already installed..."
fi

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "dockervscode_bootstrap.sh completed."