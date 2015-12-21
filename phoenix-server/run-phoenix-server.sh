#!/usr/bin/env bash

HBASE_SITE="/opt/phoenix-server/conf/hbase-site.xml"

addConfig () {

    if [ $# -ne 3 ]; then
        echo "There should be 3 arguments to addConfig: <file-to-modify.xml>, <property>, <value>"
        echo "Given: $@"
        exit 1
    fi

    xmlstarlet ed -L -s "/configuration" -t elem -n propertyTMP -v "" \
     -s "/configuration/propertyTMP" -t elem -n name -v $2 \
     -s "/configuration/propertyTMP" -t elem -n value -v $3 \
     -r "/configuration/propertyTMP" -v "property" \
     $1
}

mkdir -p "$(dirname "$HBASE_SITE")" && touch "$HBASE_SITE"

echo "<?xml version=\"1.0\"?>" >> $HBASE_SITE
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> $HBASE_SITE
echo "<configuration></configuration>" >> $HBASE_SITE

: ${ZOOKEEPER_ZNODE_PARENT:?"ZOOKEEPER_ZNODE_PARENT is required."}}
addConfig $HBASE_SITE "zookeeper.znode.parent" /$ZOOKEEPER_ZNODE_PARENT

: ${HBASE_ZOOKEEPER_QUORUM:?"HBASE_ZOOKEEPER_QUORUM is required."}
addConfig $HBASE_SITE "hbase.zookeeper.quorum" $HBASE_ZOOKEEPER_QUORUM

addConfig $HBASE_SITE "hbase.zookeeper.property.clientPort"$ {HBASE_ZOOKEEPER_PROPERTY_CLIENTPORT:=2181}

export HBASE_CONF_DIR=/opt/phoenix/conf
gosu hbase /opt/phoenix-server/bin/queryserver.py