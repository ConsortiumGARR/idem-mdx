#!/bin/bash
start=`date +%s`
mkdir -p ${DATADIR} && cd ${DATADIR}

if [ -z "${PIPELINE}" ]; then
   export PIPELINE="mdx-batch.fd"
fi

if [ ! -f "${PIPELINE}" ]; then
   cp /mdx-batch.fd "${PIPELINE}"
fi

mkdir -p /var/run
mkdir -p /logs

mkdir -p /opt/pyff/idem
mkdir -p /opt/pyff/edugain
mkdir -p /opt/pyff/idem-test

mkdir -p /opt/pyff/idem/entities
mkdir -p /opt/pyff/edugain/entities
mkdir -p /opt/pyff/idem-test/entities

mkdir -p /opt/pyff/certs
cp /certs/${MDX_CERTNAME} /opt/pyff/certs
cp /certs/${MDX_PUBKEY} /opt/pyff/certs

touch /opt/pyff/last_update

rm /opt/pyff/edugain/entities/*
rm /opt/pyff/idem/entities/*
rm /opt/pyff/idem-test/entities/*

/usr/local/bin/pyff --logfile=/dev/stdout --loglevel=${LOGLEVEL} /opt/pyff/idem-prod-batch.fd
/usr/local/bin/pyff --logfile=/dev/stdout --loglevel=${LOGLEVEL} /opt/pyff/edugain-batch.fd
/usr/local/bin/pyff --logfile=/dev/stdout --loglevel=${LOGLEVEL} /opt/pyff/idem-test-batch.fd
/usr/local/bin/pyff --logfile=/dev/stdout --loglevel=${LOGLEVEL} /opt/pyff/prod-and-test-batch.fd

end=`date +%s`
a=$(($end-$start))
c=$((3600-$a))

sleep $c
