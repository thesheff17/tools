FROM ubuntu:22.04

# to build:
# time docker build . -t thesheff17/monitoring:latest

# docker run -it -p 3000:3000 -p 9100:9100 -p 9000:9000 thesheff17/monitoring:latest /bin/bash

RUN \
    apt-get update && \
    apt-get install -y sudo systemctl vim wget
    
add ./install.sh /root/
# RUN cd /root/ 
# && ./install.sh

CMD ["/bin/bash"]
