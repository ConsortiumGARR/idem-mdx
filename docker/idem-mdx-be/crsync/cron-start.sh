#!/bin/bash

echo "${HOST1IP}	${HOST1NAME}" >> /etc/hosts
echo "${HOST2IP}        ${HOST2NAME}" >> /etc/hosts
echo "${HOST3IP}        ${HOST3NAME}" >> /etc/hosts

sed -i "s/\\\${HOST1IP}/$HOST1IP/" /etc/hosts
sed -i "s/\\\${HOST1NAME}/$HOST1NAME/" /etc/hosts
sed -i "s/\\\${HOST2IP}/$HOST2IP/" /etc/hosts
sed -i "s/\\\${HOST2NAME}/$HOST2NAME/" /etc/hosts
sed -i "s/\\\${HOST3IP}/$HOST3IP/" /etc/hosts
sed -i "s/\\\${HOST3NAME}/$HOST3NAME/" /etc/hosts

sed -i "s/\\\${HOST1NAME}/$HOST1NAME/" /usr/local/bin/rsync-mdq.sh
sed -i "s/\\\${HOST2NAME}/$HOST2NAME/" /usr/local/bin/rsync-mdq.sh
sed -i "s/\\\${HOST3NAME}/$HOST3NAME/" /usr/local/bin/rsync-mdq.sh

sed -i "s/\\\${SSH_PRIV_KEY}/$SSH_PRIV_KEY/" /usr/local/bin/rsync-mdq.sh

cron
exec tail -f /var/log/cron.log
