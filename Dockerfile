FROM ubuntu:xenial AS build_step
LABEL maintainer Ryan Shaw <ryan@rshaw.me>

RUN set -ex ; \
    mkdir -p /tuxcoin ; \
    apt-get update -y    ; \
     	apt-get install -yq \
        git                 \
        build-essential     \
        libtool             \
        autotools-dev       \
        automake            \
        pkg-config          \
        libssl-dev          \
        libevent-dev        \
        bsdmainutils        \
        libboost-all-dev    \
		software-properties-common ; \ 
	add-apt-repository ppa:bitcoin/bitcoin ; \ 
	apt-get update ; \
	apt-get install -yq libdb4.8-dev libdb4.8++-dev

ADD . /tuxcoin

RUN set -ex ; \
	cd /tuxcoin ; \
	./autogen.sh ; \
	./configure --with-gui=no --disable-tests --disable-gui-tests --disable-bench; \ 
    make clean ; \
	make

FROM ubuntu:xenial

ADD ./bin /usr/local/bin

VOLUME ["/root/.tuxcoin"]

EXPOSE 42071 42075 42072

WORKDIR /root/.tuxcoin

COPY --from=build_step /tuxcoin/src/tuxcoin* /usr/local/bin/
COPY --from=build_step /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=build_step /usr/lib/libdb_cxx-4.8.so /usr/lib/libdb_cxx-4.8.so
COPY --from=build_step /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /lib/x86_64-linux-gnu/libcrypto.so.1.0.0

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["tux_oneshot"]