FROM ubuntu:16.04
MAINTAINER yhiblog <shui.azurewebsites.net>

RUN apt-get update && \
    apt-get install -y build-essential golang git mercurial openssl curl unzip

RUN git clone https://github.com/inconshreveable/ngrok.git /ngrok && mkdir -p /myfiles/bin

ADD *.sh /

ENV DOMAIN **None**
ENV MY_FILES /myfiles
ENV TUNNEL_ADDR :4443
ENV HTTP_ADDR :80
ENV HTTPS_ADDR :443

EXPOSE 4443
EXPOSE 80
EXPOSE 443
EXPOSE 3600
EXPOSE 4500

CMD /bin/sh /server.sh
