FROM debian:10.12

# this will be a quick way to test boot.sh script.

# it also helps to have an apt-cacher-ng container
# mkdir /tmp/cache
# docker run -d -p 3142:3142 -v /tmp/cache:/var/cache/apt-cacher-ng thesheff17/apt-cacher-ng

# to build:
# time docker build . -t thesheff17/vscode:latest

RUN  echo 'Acquire::http { Proxy "http://172.17.0.2:3142"; };' >> /etc/apt/apt.conf.d/01proxy
RUN \
    apt-get update && \
    apt-get install -y sudo
    
add ./bootstrap.sh /root/
RUN cd /root/ && ./bootstrap.sh

CMD ["/bin/bash"]