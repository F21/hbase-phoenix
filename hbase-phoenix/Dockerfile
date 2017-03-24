FROM f21global/hbase:1.2.4
MAINTAINER Francis Chuang <francis.chuang@boostport.com>

ENV HBASE_MINOR_VERSION 1.2
ENV PHOENIX_VERSION 4.10.0

RUN apk --no-cache --update add bash ca-certificates gnupg openssl su-exec tar \
 && update-ca-certificates \
\
# Set up directories
 && mkdir -p /opt/phoenix \
 && mkdir -p /tmp/phoenix \
\
# Download phoenix
 && wget -O /tmp/KEYS https://www-us.apache.org/dist/phoenix/KEYS \
 && gpg --import /tmp/KEYS \
 && wget -q -O /tmp/phoenix.tar.gz http://apache.uberglobalmirror.com/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-bin.tar.gz \
 && wget -O /tmp/phoenix.asc https://www-eu.apache.org/dist/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-bin.tar.gz.asc \
 && gpg --verify /tmp/phoenix.asc /tmp/phoenix.tar.gz \
 && tar -xzf /tmp/phoenix.tar.gz -C /tmp/phoenix --strip-components 1 \
 && chown -R hbase:hadoop /tmp/phoenix \
\
# Set up HBase and Phoenix
 && mv /tmp/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-server.jar /opt/hbase/lib/ \
 && mv /tmp/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-client.jar /opt/hbase/lib/ \
 && mv /tmp/phoenix/bin/tephra /opt/hbase/bin/tephra \
 && mv /tmp/phoenix/bin/tephra-env.sh /opt/hbase/bin/tephra-env.sh \
\
# Replace hbase's guava 12 jar with the guava 13 jar. Remove when TEPHRA-181 is resolved.
 && rm /opt/hbase/lib/guava-12.0.1.jar \
 && wget -P /opt/hbase/lib https://search.maven.org/remotecontent?filepath=com/google/guava/guava/13.0.1/guava-13.0.1.jar \
 && chown hbase:hadoop /opt/hbase/lib/guava-13.0.1.jar \
\
# Clean up
 && apk del gnupg openssl tar \
 && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

ADD run-hbase-phoenix.sh /run-hbase-phoenix.sh

EXPOSE 16010 16020 16030

CMD ["/run-hbase-phoenix.sh"]