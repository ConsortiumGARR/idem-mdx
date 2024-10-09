#!/bin/bash

if [ -f "/opt/idem_xml_to_jwt/${MDX_ENCRYPTEDKEY}" ]; then
   openssl rsa -in "/opt/idem_xml_to_jwt/${MDX_ENCRYPTEDKEY}" --passin pass:"${PYFF_PASSPHRASE}" -out "/opt/idem_xml_to_jwt/${MDX_KEY}"
   rm "/opt/idem_xml_to_jwt/${MDX_ENCRYPTEDKEY}"
fi

if [ -f "/opt/idem_xml_to_jwt/createToken.py.template" ]; then
   gomplate -f /opt/idem_xml_to_jwt/createToken.py.template -o /opt/idem_xml_to_jwt/createToken.py
   rm /opt/idem_xml_to_jwt/createToken.py.template
fi

if [ -f "/usr/local/bin/rsync-mdq.sh.template" ]; then
   gomplate -f /usr/local/bin/rsync-mdq.sh.template -o /usr/local/bin/rsync-mdq.sh
   chmod 0755 /usr/local/bin/rsync-mdq.sh
   rm /usr/local/bin/rsync-mdq.sh.template
fi

# Add hosts to /etc/hosts
echo "${HOST1IP}        ${HOST1NAME}" >> /etc/hosts
echo "${HOST2IP}        ${HOST2NAME}" >> /etc/hosts
echo "${HOST3IP}        ${HOST3NAME}" >> /etc/hosts

sed -i "s/\\\${HOST1IP}/$HOST1IP/" /etc/hosts
sed -i "s/\\\${HOST1NAME}/$HOST1NAME/" /etc/hosts
sed -i "s/\\\${HOST2IP}/$HOST2IP/" /etc/hosts
sed -i "s/\\\${HOST2NAME}/$HOST2NAME/" /etc/hosts
sed -i "s/\\\${HOST3IP}/$HOST3IP/" /etc/hosts
sed -i "s/\\\${HOST3NAME}/$HOST3NAME/" /etc/hosts

cron
exec tail -f /var/log/cron.log
