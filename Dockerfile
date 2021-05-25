FROM ubuntu:18.04 as downloader

RUN apt update \
  && apt install wget gpg -y \
  && wget -qO - https://facebook.github.io/mcrouter/debrepo/bionic/PUBLIC.KEY | apt-key add \
  && echo 'deb https://facebook.github.io/mcrouter/debrepo/bionic bionic contrib' | tee -a /etc/apt/sources.list \
  && apt-get update \
  && apt download mcrouter \
  && mv mcrouter*.deb mcrouter.deb

FROM ubuntu:18.04

COPY --from=downloader /mcrouter.deb /tmp/

RUN apt update \
  && apt install -y \
      libboost-context1.65.1 \
      libboost-filesystem1.65.1 \
      libboost-program-options1.65.1 \
      libboost-regex1.65.1 \
      libboost-system1.65.1 \
      libdouble-conversion1 \
      libevent-2.1-6 \
      libgflags2.2 \
      libgoogle-glog0v5 \
      libsodium23 \
      libssl1.1 \
      libunwind8 \
      openssl \
  && dpkg -i /tmp/mcrouter.deb \
  && rm -f /tmp/mcrouter.deb \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT [ "mcrouter" ]
