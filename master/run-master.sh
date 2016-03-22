#!/usr/bin/env bash

HBASE_SITE="/opt/hbase/conf/hbase-site.xml"

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

# Phoenix config
addConfig $HBASE_SITE "hbase.master.loadbalancer.class" "org.apache.phoenix.hbase.index.balancer.IndexLoadBalancer"
addConfig $HBASE_SITE "hbase.coprocessor.master.classes" "org.apache.phoenix.hbase.index.master.IndexMasterObserver"
addConfig $HBASE_SITE "data.tx.snapshot.dir" "/tmp/tephra/snapshots"
addConfig $HBASE_SITE "data.tx.timeout" "60"

gosu hbase /opt/phoenix/bin/tephra

/run-master.sh