FROM debian:wheezy

RUN groupadd -r mosquitto && useradd -r -g mosquitto mosquitto

RUN apt-get update && apt-get install -y --no-install-recommends \
				curl \
		&& rm -rf /var/lib/apt/lists/*

ENV ARES_DOWNLOAD_URL http://c-ares.haxx.se/download/c-ares-1.10.0.tar.gz
ENV ARES_DOWNLOAD_SHA1 e44e6575d5af99cb3a38461486e1ee8b49810eb5
ENV MOSQUITTO_VERSION 1.4.5
ENV MOSQUITTO_DOWNLOAD_URL http://mosquitto.org/files/source/mosquitto-1.4.5.tar.gz
ENV MOSQUITTO_DOWNLOAD_SHA1 3ada1597974bd8f8b69a4ecb93cfd23a2608a630

RUN buildDeps='gcc g++ libc6-dev libssl-dev uuid-dev make' \
		&& set -x \
		&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
		&& rm -rf /var/lib/apt/lists/* \
		&& mkdir -p /usr/src/ares \
		&& curl -sSL "$ARES_DOWNLOAD_URL" -o ares.tar.gz \
		&& echo "$ARES_DOWNLOAD_SHA1 *ares.tar.gz" | sha1sum -c - \
		&& tar -xzf ares.tar.gz -C /usr/src/ares --strip-components=1 \
		&& rm ares.tar.gz \
		&& cd /usr/src/ares; ./configure; cd ~ \
		&& make -C /usr/src/ares \
		&& make -C /usr/src/ares install \
		&& rm -r /usr/src/ares \
		&& mkdir -p /usr/src/mosquitto \
		&& curl -sSL "$MOSQUITTO_DOWNLOAD_URL" -o mosquitto.tar.gz \
		&& echo "$MOSQUITTO_DOWNLOAD_SHA1 *mosquitto.tar.gz" | sha1sum -c - \
		&& tar -xzf mosquitto.tar.gz -C /usr/src/mosquitto --strip-components=1 \
		&& rm mosquitto.tar.gz \
		&& make -C /usr/src/mosquitto \
		&& make -C /usr/src/mosquitto install \
		&& rm -r /usr/src/mosquitto \
		&& apt-get purge -y --auto-remove $buildDeps

COPY mosquitto.conf /etc/mosquitto/mosquitto.conf

EXPOSE 1883
CMD [ "mosquitto","-c","/etc/mosquitto/mosquitto.conf" ]