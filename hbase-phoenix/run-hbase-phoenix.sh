#!/usr/bin/env bash

: ${HBASE_ROLE:?"HBASE_ROLE is required and should be master or regionserver."}

source roles/boostrap.sh

function stop_master {
    /opt/hbase/bin/stop-hbase.sh
    /opt/hbase/bin/tephra stop

    exit
}

export HBASE_CONF_DIR=/opt/hbase/conf
export HBASE_CP=/opt/hbase/lib
export HBASE_HOME=/opt/hbase

if [[ ${HBASE_ROLE,,} = master ]]; then

    # Phoenix config
    addConfig $HBASE_SITE "data.tx.snapshot.dir" "/tmp/tephra/snapshots"
    addConfig $HBASE_SITE "data.tx.timeout" "60"
    addConfig $HBASE_SITE "phoenix.transactions.enabled" true

    # Create directory in hdfs if it doesn't exist
    su-exec hadoop java -jar /opt/hadoop/hdfs-fs.jar -conf $HBASE_CONF_DIR/hdfs-site.xml -test -d "hdfs://${HDFS_CLUSTER_NAME}/${CLUSTER_NAME}"

    if [ $? != 0 ]; then
        su-exec hadoop java -jar /opt/hadoop/hdfs-fs.jar -conf $HBASE_CONF_DIR/hdfs-site.xml -mkdir "hdfs://${HDFS_CLUSTER_NAME}/${CLUSTER_NAME}"
        su-exec hadoop java -jar /opt/hadoop/hdfs-fs.jar -conf $HBASE_CONF_DIR/hdfs-site.xml -chown hbase "hdfs://${HDFS_CLUSTER_NAME}/${CLUSTER_NAME}"
    fi

    trap stop_master SIGINT SIGTERM

    echo "Starting hbase master..."

    su-exec hbase /opt/hbase/bin/hbase --config /opt/hbase/conf master start &

    echo "Starting tephra transaction server..."
    su-exec hbase /opt/hbase/bin/tephra start &

    while true; do sleep 1; done

elif [[ ${HBASE_ROLE,,} = regionserver ]]; then

    # Phoenix config
    addConfig $HBASE_SITE "hbase.regionserver.wal.codec" "org.apache.hadoop.hbase.regionserver.wal.IndexedWALEditCodec"
    addConfig $HBASE_SITE "hbase.region.server.rpc.scheduler.factory.class" "org.apache.hadoop.hbase.ipc.PhoenixRpcSchedulerFactory"
    addConfig $HBASE_SITE "hbase.rpc.controllerfactory.class" "org.apache.hadoop.hbase.ipc.controller.ServerRpcControllerFactory"

    echo "Starting hbase regionserver..."

    exec su-exec hbase /opt/hbase/bin/hbase --config /opt/hbase/conf regionserver start

else
    echo "HBASE_ROLE's value must be one of: master or regionserver"
    exit 1
fi