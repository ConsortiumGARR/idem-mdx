#!/bin/bash

if [ -f "/opt/pyff/idem-test/idem-test-idps.xml" ]; then 
        tar -cf - --exclude last_update /opt/pyff | sha1sum > /opt/pyff/last_update
        for HOST in ${HOST1NAME} ${HOST2NAME} ${HOST3NAME}
        do
                rsync -rl -s -e "ssh -i /ssh/mdqsync-key -o 'StrictHostKeyChecking=no'" /opt/pyff/ mdqsync@$HOST:/opt/idem-mdq-data/
                if [ "$?" -eq "0" ]
                then
                        echo "$(date): MDQ rsync $HOST effettuato!" >> /var/log/cron.log 2>&1
                fi
        done
fi
