# runtime stage
FROM debian:stretch-slim

ENV FILE=monero-linux-x64-v0.15.0.0.tar.bz2
ENV FILE_CHECKSUM=53d9da55137f83b1e7571aef090b0784d9f04a980115b5c391455374729393f3
RUN apt-get update \
    && apt-get -y --no-install-recommends install bzip2 ca-certificates wget curl
	
RUN wget -qO $FILE https://dlsrc.getmonero.org/cli/$FILE 

RUN echo "$FILE_CHECKSUM $FILE" | sha256sum -c - 
RUN mkdir -p extracted 
RUN tar -jxvf $FILE -C /extracted 
RUN find /extracted/ -type f -print0 | xargs -0 chmod a+x
RUN find /extracted/ -type f -print0 | xargs -0 mv -t /usr/local/bin/
RUN rm -rf extracted && rm $FILE 
RUN apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

COPY ./scripts /scripts/
RUN find /scripts/ -type f -print0 | xargs -0 chmod a+x
# Create monero user
RUN adduser --system --group --disabled-password monero && \
	mkdir -p /wallet /home/monero/.bitmonero && \
	chown -R monero:monero /home/monero/.bitmonero && \
	chown -R monero:monero /wallet

VOLUME /home/monero/.bitmonero
VOLUME /wallet

EXPOSE 18080
EXPOSE 18081
EXPOSE 18082
# switch to user monero
USER monero


