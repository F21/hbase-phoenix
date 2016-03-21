# HBase Phoenix Query Server

FROM f21global/java:8
MAINTAINER Francis Chuang <francis.chuang@boostport.com>

ENV HBASE_MAJOR_VER 1.1
ENV PHOENIX_VER 4.7.0

RUN groupadd hadoop \
    && adduser --system --home /opt/phoenix-server --disabled-login --ingroup hadoop hbase \
    && apt-get update \
    && apt-get install --no-install-recommends ca-certificates python xmlstarlet -y \
    && mkdir -p /opt/phoenix-server \
    && mkdir -p /tmp/phoenix \
    && wget -q -O - http://apache.uberglobalmirror.com/phoenix/phoenix-$PHOENIX_VER-HBase-$HBASE_MAJOR_VER/bin/phoenix-$PHOENIX_VER-HBase-$HBASE_MAJOR_VER-bin.tar.gz | tar -xzf - -C /tmp/phoenix --strip-components 1 \
    && mv /tmp/phoenix/phoenix-server-$PHOENIX_VER-HBase-$HBASE_MAJOR_VER-runnable.jar /opt/phoenix-server/ \
    && mv /tmp/phoenix/bin /opt/phoenix-server/bin \
    && rm -rf /tmp/phoenix \
    && chown -R hbase:hadoop /opt/phoenix-server

RUN arch="$(dpkg --print-architecture)" \
	&& set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.7/gosu-$arch" \
	&& chmod +x /usr/local/bin/gosu

ADD run-phoenix-server.sh /run-phoenix-server.sh

EXPOSE 8765

CMD ["/run-phoenix-server.sh"]